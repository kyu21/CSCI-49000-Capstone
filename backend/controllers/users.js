const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");
var bcrypt = require("bcrypt");
const saltRounds = 10;

const userController = {
	getAllUsers: getAllUsers,
	getUserById: getUserById,
	getLoggedInUser: getLoggedInUser,
	editUser: editUser,
	deleteUser: deleteUser
};

async function getAllUsers(req, res, next) {
	try {
		const users = await db.users.findAll();
		res.status(200).json(users);
	} catch (err) {
		console.log(err);
	}
}

async function getDetailedUserInfo(userId, user) {
	try {
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
		const allUserPosts = await db.posts.findAll({
			raw: true,
			where: {
				ownerId: userId,
			},
		});

		// post interests
		const interests = await db.postInterests.findAll({
			raw: true,
			where: {
				userId: userId
			}
		})
		const allInterestInfo = await Promise.all(
			interests.map(
				async (p) => (
					await db.posts.findOne({
						raw: true,
						where: {
							id: p.postId
						}
					})
				)
			)
		)


		user["zips"] = allZipsInfo;
		user["languages"] = allLangInfo;
		user["posts"] = allUserPosts;
		user["interests"] = allInterestInfo;

		return user;
	} catch (err) {
		console.log(err);
	}
}

async function getLoggedInUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		user = await getDetailedUserInfo(currentUser.id, currentUser);
		res.status(200).json(user);
	} catch (err) {
		console.log(err);
	}
}

async function getUserById(req, res, next) {
	try {
		const {
			userId
		} = req.params;

		var user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		user = await getDetailedUserInfo(userId, user);

		res.status(200).json(user);
	} catch (err) {
		console.log(err);
	}
}

async function editUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		const validKeys = [
			"first",
			"last",
			"gender",
			"phone",
			"email",
			"password",
		];
		let newInfo = {};
		for (let key in req.body) {
			if (validKeys.indexOf(key) >= 0) {
				newInfo[key] = req.body[key];
				if (key === "password") {
					let hashedPassword = await bcrypt.hash(
						req.body[key],
						saltRounds
					);
					newInfo[key] = hashedPassword;
				}
			}
		}

		let [_, users] = await db.users.update(newInfo, {
			where: {
				id: currentUser.id
			},
			returning: true,
			raw: true,
		});

		res.status(200).json(users[0]);
	} catch (err) {
		console.log(err);
	}
}

async function deleteUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		await db.users.destroy({
			where: {
				id: currentUser.id
			},
		});
		await cascadeDelete(currentUser.id);

		res.status(200).json({
			code: "Success",
		});
	} catch (err) {
		console.log(err);
	}
}

async function cascadeDelete(userId) {
	try {
		await db.userZips.destroy({
			where: {
				userId: userId
			}
		})
		await db.userLanguages.destroy({
			where: {
				userId: userId
			}
		})
		let posts = await db.posts.findAll({
			where: {
				ownerId: userId
			}
		})
		let postIds = posts.map((p) => (p.id))
		await posts.forEach((p) => p.destroy())
		await db.postZips.destroy({
			where: {
				postId: postIds
			}
		})
	} catch (err) {
		console.log(err);
	}
}

async function getLoggedInUserInterested(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});



	} catch (err) {
		console.log(err);
	}
}

module.exports = userController;