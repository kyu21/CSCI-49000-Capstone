const e = require("express");
const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");

require('@gouch/to-title-case');

const {
	standardizePostObject,
	cascadeDeletePost
} = require("../utils/standardize")

// GET /posts AUTH
async function getAllPosts(req, res) {
	try {
		let posts = await db.posts.findAll({
			raw: true
		});

		posts = await Promise.all(
			posts.map(
				async (e) => await standardizePostObject(e)
			)
		);

		res.status(200).json(posts)
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting all posts, please try again.",
		});
	}
}

// GET /posts/me AUTH
async function getLoggedInUserPosts(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		let posts = await db.posts.findAll({
			raw: true,
			where: {
				ownerId: currentUser.id
			}
		});

		if (posts.length !== 0) {
			posts = await Promise.all(
				posts.map(
					async (e) => await standardizePostObject(e)
				)
			);
		}

		res.status(200).json(posts);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting logged in user's posts, please try again.",
		});
	}
}

// GET /posts/:postId AUTH
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
		post = await standardizePostObject(post);

		res.status(200).json(post);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting post, please try again.",
		});
	}
}

// POST /posts AUTH
async function createPost(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		// parse body, add owner info and create post
		let postInfo = req.body;
		postInfo["ownerId"] = currentUser.id;

		const requiredKeys = ["ownerId", "title", "description", "is_request", "free"];
		const hasRequiredKeys = requiredKeys.every((e) => e in postInfo);

		if (hasRequiredKeys) {
			let post = await db.posts.create(postInfo);
			post = post.get({
				plain: true
			})

			// parse additional information - zips, languages, categories
			// zips
			if ("zips" in postInfo) {
				const zips = postInfo["zips"];

				// check input for non-empty array
				if (Array.isArray(zips) && zips.length !== 0) {
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

						// create association between post and zip
						await db.postZips.create({
							postId: post.id,
							zipId: dbZip.id
						});
					}

				}
			}

			// languages
			if ("languages" in postInfo) {
				const languages = postInfo["languages"];

				// check input for non-empty array
				if (Array.isArray(languages) && languages.length !== 0) {
					for (let lang of languages) {
						lang = lang.toTitleCase()

						// check db if language exists
						let dbLang = await db.languages.findOne({
							raw: true,
							where: {
								name: lang
							}
						});

						// create entry for language if not in table already
						if (dbLang === null) {
							dbLang = await db.languages.create({
								name: lang
							});
						}

						// create association between post and language
						await db.postLanguages.create({
							postId: post.id,
							languageId: dbLang.id
						});
					}
				}
			}

			// categories
			if ("categories" in postInfo) {
				const categories = postInfo["categories"];

				// check input for non-empty array
				if (Array.isArray(categories) && categories.length !== 0) {
					for (let category of categories) {
						category = category.toTitleCase()

						// check db if category exists
						let dbCategory = await db.categories.findOne({
							raw: true,
							where: {
								name: category
							}
						});

						// create entry for category if not in table already
						if (dbCategory === null) {
							dbCategory = await db.categories.create({
								name: category
							});
						}

						// create association between post and category
						await db.postCategories.create({
							postId: post.id,
							categoryId: dbCategory.id
						});
					}
				}
			}

			post = await standardizePostObject(post);

			res.status(201).json(post);
		} else {
			res.status(400).json({
				code: "Error",
				message: "Error creating post, missing required arguments, please try again.",
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error creating post, please try again.",
		});
	}
}

// PUT /posts/:postId AUTH
async function editPost(req, res) {
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

		// check if post exists
		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId
			}
		});
		if (post !== null) {
			// check if logged in user is owner of post
			if (post.ownerId === currentUser.id) {
				let invalidInput = false;

				let newInfo = {};

				// check if body has valid keys
				const validKeys = ["title", "description", "address", "is_request", "free"];

				for (let key in req.body) {
					let val = req.body[key];

					// check for correct input type and nonempty input
					if ((validKeys.slice(0, 3).indexOf(key) > -1 && typeof val === "string" && val.length !== 0) || (validKeys.slice(3).indexOf(key) > -1 && typeof val === "boolean")) {
						newInfo[key] = val;
					} else {
						invalidInput = true;
						break;
					}
				}

				if (invalidInput) {
					res.status(400).json({
						code: "Error",
						message: `Invalid input, please try again.`,
					});
				} else {
					let [_, posts] = await db.posts.update(newInfo, {
						where: {
							id: postId
						},
						returning: true,
						raw: true,
					});

					let editedPost = await standardizePostObject(posts[0]);

					res.status(200).json(editedPost);
				}
			} else {
				res.status(403).json({
					code: "Error",
					message: `User ${currentUser.id} is not creator of post ${postId}, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} does not exist, please try again.`,
			});
		}

	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error editing post, please try again.`,
		});
	}
}

// DELETE /posts/:postId AUTH
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
			where: {
				id: postId
			}
		});

		// check if post exists
		if (post !== null) {
			// check if logged in user is owner of post
			if (post.ownerId === currentUser.id) {
				await post.destroy();
				await cascadeDeletePost(postId);

				res.sendStatus(204);
			} else {
				res.status(403).json({
					code: "Error",
					message: `User ${currentUser.id} is not creator of post ${postId}, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} does not exist, please try again.`,
			});
		}

	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error deleting post, please try again.",
		});
	}
}

module.exports = {
	getAllPosts: getAllPosts,
	getLoggedInUserPosts: getLoggedInUserPosts,
	getPostById: getPostById,
	createPost: createPost,
	editPost: editPost,
	deletePost: deletePost,
};