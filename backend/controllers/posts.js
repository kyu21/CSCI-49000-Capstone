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

			let postZips = await db.postZips.findAll({
				raw: true,
				where: {
					postId: post.id
				}
			});
			let zips = await Promise.all(postZips.map(async (z) => (
				await db.zips.findOne({
					raw: true,
					where: {
						id: z.zipId
					}
				})
			)));

			postObj.push({
				owner: user,
				post: post,
				zips: zips
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

		let posts = await db.posts.findAll({
			raw: true,
			where: whereClause
		});
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
			where: {
				email: decodedJwt.email
			},
		});

		let whereClause = {
			ownerId: currentUser.id
		};
		const postType = req.query.postType;
		if (postType === "request") {
			whereClause.is_request = true;
		} else if (postType === "offer") {
			whereClause.is_request = false;
		}

		let posts = await db.posts.findAll({
			raw: true,
			where: whereClause
		});

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
			where: {
				email: decodedJwt.email
			},
		});
		const {
			title,
			description,
			is_request,
			free
		} = req.body;

		let address = null
		if (req.body.address) {
			address = req.body.address
		}

		const newPost = {
			title: title,
			description: description,
			address: address,
			is_request: is_request,
			free: free,
			ownerId: currentUser.id,
		};

		let post = await db.posts.create(newPost);

		const zips = req.body.zips;
		if (zips !== undefined) {
			for (const zip of zips) {
				let dbZip = await db.zips.findOne({
					raw: true,
					where: {
						zip: zip
					}
				});

				if (dbZip === null) {
					// create zip
					dbZip = await db.zips.create({
						zip: zip
					})

				}

				await db.postZips.create({
					postId: post.id,
					zipId: dbZip.id
				})
			}
		}

		res.status(201).json(post);
	} catch (err) {
		console.log(err);
	}
}

async function getPostById(req, res) {
	try {
		const {
			postId
		} = req.params;
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
			where: {
				email: decodedJwt.email
			},
		});

		const validKeys = ["title", "description", "address", "is_request", "free"];
		let newInfo = {};
		for (let key in req.body) {
			if (validKeys.indexOf(key) >= 0) {
				newInfo[key] = req.body[key];
			}
		}

		const {
			postId
		} = req.params;
		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId
			}
		});

		if (post.ownerId === currentUser.id) {
			let [_, posts] = await db.posts.update(newInfo, {
				where: {
					id: postId
				},
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
			where: {
				email: decodedJwt.email
			},
		});

		const {
			postId
		} = req.params;
		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId
			}
		});

		if (post.ownerId === currentUser.id) {
			await db.posts.destroy({
				where: {
					id: postId
				},
			});

			await cascadeDelete(postId)

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

async function cascadeDelete(postId) {
	try {
		await db.postZips.destroy({
			where: {
				postId: postId
			}
		})
		await db.postInterests.destroy({
			where: {
				postId: postId
			}
		})
	} catch (err) {
		console.log(err);
	}
}

module.exports = postController;