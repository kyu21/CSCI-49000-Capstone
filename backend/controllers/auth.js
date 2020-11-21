const db = require("../models");

const jwt = require("jsonwebtoken");
var bcrypt = require("bcrypt");
const accessTokenSecret = "youraccesstokensecret";
const saltRounds = 10;

require('@gouch/to-title-case');

const {
	standardizeUserObject
} = require("../utils/standardize")

// POST /auth/login
async function login(req, res) {
	try {
		// find if user exists
		const {
			email,
			password
		} = req.body;
		const user = await db.users.findOne({
			raw: true,
			where: {
				email: email
			},
		});

		if (user) {
			const match = await bcrypt.compare(password, user.password);
			if (match) {
				const accessToken = jwt.sign({
						email: user.email
					},
					accessTokenSecret
				);
				res.status(200).json({
					accessToken
				});
			} else {
				res.status(401).json({
					code: "Error",
					message: "Email or password is wrong.",
				});
			}
		} else {
			res.status(401).json({
				code: "Error",
				message: "Email or password is wrong.",
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error logging in, please try again.",
		});
	}
}

// POST /auth/register
async function register(req, res) {
	try {
		// check if email is duplicate
		let newUser = req.body;
		const userExists = await db.users.findOne({
			where: {
				email: newUser.email
			},
		});

		if (!userExists) {
			// hash password and create user
			let hashedPassword = await bcrypt.hash(
				newUser.password,
				saltRounds
			);
			newUser.password = hashedPassword;
			let user = await db.users.create(newUser);
			user = user.get({
				plain: true
			})

			// parse additonal information - zips and languages
			const zips = newUser.zips;
			if (typeof zips === "object" && zips.length !== 0) {
				for (const zip of zips) {
					// check db if zip exists
					let dbZip = await db.zips.findOne({
						raw: true,
						where: {
							zip: zip
						}
					});

					// create entry for zip if not in table already
					if (dbZip === null) {
						dbZip = await db.zips.create({
							zip: zip
						});
					}

					// create association between user and zip
					await db.userZips.create({
						userId: user.id,
						zipId: dbZip.id
					});
				}
			}

			// languages
			const languages = newUser.languages;
			if (typeof languages === "object" && languages.length !== 0) {
				for (let lang of languages) {
					lang = lang.toTitleCase()

					// check db if language exists
					let dbLang = await db.languages.findOne({
						raw: true,
						where: {
							name: lang
						}
					});

					// create entry for zip if not in table already
					if (dbLang === null) {
						dbLang = await db.languages.create({
							name: lang
						});
					}

					// create association between user and zip
					await db.userLanguages.create({
						userId: user.id,
						languageId: dbLang.id
					});
				}
			}

			user = await standardizeUserObject(user);

			res.status(201).json(user);
		} else {
			res.status(401).json({
				code: "Error",
				message: "Email exists."
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error with creating account. Please retry.",
		});
	}
}

module.exports = {
	login: login,
	register: register,
};