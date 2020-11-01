const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");

const userController = {
	getAllUsers: getAllUsers,
	getUserById: getUserById,
	getLoggedInUser: getLoggedInUser,
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

		return user;
	} catch (err) {
		console.log(err);
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

		user = await getDetailedUserInfo(userId, user);

		res.status(200).json(user);
	} catch (err) {
		console.log(err);
	}
}

async function getLoggedInUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: { email: decodedJwt.email },
		});

		user = await getDetailedUserInfo(currentUser.id, currentUser);
		res.status(200).json(user);
	} catch (err) {
		console.log(err);
	}
}

module.exports = userController;
