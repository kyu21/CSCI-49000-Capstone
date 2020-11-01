const db = require("../models");

const postController = {
	getAllPosts: getAllPosts,
	createPost: createPost,
	getPostById: getPostById,
};

async function getAllPosts(req, res) {
	try {
		const posts = await db.posts.findAll();
		let postObj = [];

		for (let post of posts) {
			let postId = post.id;
			let userPostObj = await db.userPosts.findOne({
				raw: true,
				where: {
					postId: postId,
				},
			});
			let userId = userPostObj.userId;

			let user = await db.users.findOne({
				raw: true,
				where: {
					id: userId,
				},
			});

			let postOwner = {
				id: user.id,
				first: user.first,
				last: user.last,
			};
			postObj.push({
				owner: postOwner,
				post: post,
			});
		}

		res.status(200).json(postObj);
	} catch (err) {
		console.log(err);
	}
}

async function createPost(req, res) {
	try {
		const { userId } = req.params;

		let post = await db.posts.create(req.body);

		await db.userPosts.create({
			userId: userId,
			postId: post.id,
		});

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

		let userPostObj = await db.userPosts.findOne({
			raw: true,
			where: {
				postId: postId,
			},
		});
		let userId = userPostObj.userId;
		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});
		let postOwner = {
			id: user.id,
			first: user.first,
			last: user.last,
		};

		let postObj = {
			owner: postOwner,
			post: post,
		};
		res.status(201).json(postObj);
	} catch (err) {
		console.log(err);
	}
}

module.exports = postController;
