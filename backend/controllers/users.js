const db = require("../models");

var bcrypt = require("bcrypt");
const saltRounds = 10;

const userController = {
	getAllUsers: getAllUsers,
	createUser: createUser,
	getUserById: getUserById,
	registerUser: registerUser,
};

async function getAllUsers(req, res, next) {
	try {
		const users = await db.users.findAll();
		res.status(200).json(users);
	} catch (err) {
		console.log(err);
	}
}

async function createUser(req, res, next) {
	try {
		let newUser = req.body;
		const userExists = await db.users.findOne({
			where: {
				name: newUser.name,
			},
		});
		if (!userExists) {
			await db.users.create(newUser);
			res.status(200).json({
				code: "Success",
				message: "User created",
			});
		} else {
			res.status(401).json({
				code: "error",
				message: "Email exists.",
			});
		}
	} catch (err) {
		console.log(err);
		res.status(401).json({
			code: "error",
			message: "Error with creating account. Please retry.",
		});
	}
}

async function getUserById(req, res, next) {
	try {
		const { userId } = req.params;

		var user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		// zips
		const allUserZips = await db.userZips.findAll({
			where: {
				userId: userId,
			},
		});
		const allZipsInfo = await Promise.all(
			allUserZips.map(
				async (zipEle) =>
					await db.zips.findOne({
						raw: true,
						where: {
							id: zipEle.zipId,
						},
					})
			)
		);

		// languages
		const allUserLang = await db.userLanguages.findAll({
			where: {
				userId: userId,
			},
		});
		const allLangInfo = await Promise.all(
			allUserLang.map(
				async (langEle) =>
					await db.languages.findOne({
						raw: true,
						where: {
							id: langEle.languageId,
						},
					})
			)
		);

		// posts
		const allUserPosts = await db.userPosts.findAll({
			where: {
				userId: userId,
			},
		});
		const allPosts = await Promise.all(
			allUserPosts.map(
				async (postEle) =>
					await db.posts.findOne({
						raw: true,
						where: {
							id: postEle.postId,
						},
					})
			)
		);

		user["zips"] = allZipsInfo;
		user["languages"] = allLangInfo;
		user["posts"] = allPosts;

		res.status(200).json(user);
	} catch (err) {
		console.log(err);
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

module.exports = userController;
