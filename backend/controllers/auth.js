const db = require("../models");

const jwt = require("jsonwebtoken");
var bcrypt = require("bcrypt");
const accessTokenSecret = "youraccesstokensecret";
const saltRounds = 10;

const authController = {
	loginUser: loginUser,
	registerUser: registerUser,
};

async function loginUser(req, res, next) {
	try {
		const { email, password } = req.body;
		const user = await db.users.findOne({
			raw: true,
			where: { email: email },
		});
		if (user) {
			const match = await bcrypt.compare(password, user.password);
			if (match) {
				const accessToken = jwt.sign(
					{ email: user.email },
					accessTokenSecret
				);
				res.status(200).json({ accessToken });
			} else {
				res.status(401).json({
					code: "error",
					message: "Email or password is wrong.",
				});
			}
		} else {
			res.status(401).json({
				code: "error",
				message: "Email or password is wrong.",
			});
		}
	} catch (err) {
		console.log(err);
		res.status(401).json({
			code: "error",
			message: "Error logging in, please try again.",
		});
	}
}

async function registerUser(req, res) {
	try {
		let newUser = req.body;
		const userExists = await db.users.findOne({
			where: { email: newUser.email },
		});

		if (!userExists) {
			let hashedPassword = await bcrypt.hash(
				newUser.password,
				saltRounds
			);
			newUser.password = hashedPassword;
			let user = await db.users.create(newUser);

			res.status(201).json(user);
		} else {
			res.status(401).json({ code: "Error", message: "Email exists." });
		}
	} catch (err) {
		console.log(err);
		res.status(401).json({
			code: "error",
			message: "Error with creating account. Please retry.",
		});
	}
}

module.exports = authController;
