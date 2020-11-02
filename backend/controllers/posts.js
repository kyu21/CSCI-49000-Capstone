const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");

const postController = {
	getAllPosts: getAllPosts,
	getLoggedInUserPosts: getLoggedInUserPosts,
	createPost: createPost,
	getPostById: getPostById,
	editPost: editPost,
	deletePost: deletePost,
};

async function appendOwnerInfo(posts) {
	try {
		let postObj = [];

		for (let post of posts) {
			let userId = post.ownerId;

			let user = await db.users.findOne({
				raw: true,
				where: {
					id: userId,
				},
			});

			postObj.push({
				owner: user,
				post: post,
			});
		}

		return postObj;
	} catch (err) {
		console.log(err);
	}
}

async function getAllPosts(req, res) {
	try {
		let whereClause = {};
		const postType = req.query.postType;
		if (postType === "request") {
			whereClause.is_request = true;
		} else if (postType === "offer") {
			whereClause.is_request = false;
		}

		let posts = await db.posts.findAll({ raw: true, where: whereClause });
		posts = await appendOwnerInfo(posts);

		res.status(200).json(posts);
	} catch (err) {
		console.log(err);
	}
}

async function getLoggedInUserPosts(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: { email: decodedJwt.email },
		});

		let whereClause = { ownerId: currentUser.id };
		const postType = req.query.postType;
		if (postType === "request") {
			whereClause.is_request = true;
		} else if (postType === "offer") {
			whereClause.is_request = false;
		}

		let posts = await db.posts.findAll({ raw: true, where: whereClause });

		let postsWithOwner = [];
		for (let post of posts) {
			postsWithOwner.push({
				owner: currentUser,
				post: post,
			});
		}

		res.status(200).json(postsWithOwner);
	} catch (err) {
		console.log(err);
	}
}

async function createPost(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: { email: decodedJwt.email },
		});
		const { title, description, is_request } = req.body;
		const newPost = {
			title: title,
			description: description,
			is_request: is_request,
			ownerId: currentUser.id,
		};

		let post = await db.posts.create(newPost);

		res.status(201).json(post);
	} catch (err) {
		console.log(err);
	}
}

async function getPostById(req, res) {
	try {
		const { postId } = req.params;
		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});
		post = await appendOwnerInfo([post]);

		res.status(200).json(post);
	} catch (err) {
		console.log(err);
	}
}

async function editPost(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: { email: decodedJwt.email },
		});

		const validKeys = ["title", "description", "is_request"];
		let newInfo = {};
		for (let key in req.body) {
			if (validKeys.indexOf(key) >= 0) {
				newInfo[key] = req.body[key];
			}
		}

		const { postId } = req.params;
		let post = await db.posts.findOne({ raw: true, where: { id: postId } });

		if (post.ownerId === currentUser.id) {
			let [_, posts] = await db.posts.update(newInfo, {
				where: { id: postId },
				returning: true,
				raw: true,
			});

			res.status(200).json(posts[0]);
		} else {
			res.status(401).json({
				code: "Error",
				message: "Logged in user is not creator of this post.",
			});
		}
	} catch (err) {
		console.log(err);
	}
}

async function deletePost(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: { email: decodedJwt.email },
		});

		const { postId } = req.params;
		let post = await db.posts.findOne({ raw: true, where: { id: postId } });

		if (post.ownerId === currentUser.id) {
			await db.posts.destroy({
				where: { id: postId },
			});

			res.status(200).json({
				code: "Success",
			});
		} else {
			res.status(401).json({
				code: "Error",
				message: "Logged in user is not creator of this post.",
			});
		}
	} catch (err) {
		console.log(err);
	}
}

module.exports = postController;
