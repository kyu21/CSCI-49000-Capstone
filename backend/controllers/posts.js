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

		if (post !== null) {
			post = await standardizePostObject(post);

			res.status(200).json(post);
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
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
				message: `Post ${postId} not found, please try again.`,
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
				message: `Post ${postId} not found, please try again.`,
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

// GET /posts/:postId/zips AUTH
async function getPostZips(req, res) {
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

		if (post !== null) {
			let zips = await db.postZips.findAll({
				raw: true,
				where: {
					postId: postId
				}
			});
			if (zips.length !== 0) {
				zips = await db.zips.findAll({
					raw: true,
					where: {
						id: zips.map(z => z.zipId)
					}
				});
			}
			res.status(200).json(zips);
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting zips for post, please try again.",
		});
	}
}

// POST /posts/:postId/zips AUTH
async function addPostZips(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			zips
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(zips) && zips.length !== 0) {
				for (const z of zips) {
					// check db if zip exists
					let dbZip = await db.zips.findOne({
						raw: true,
						where: {
							zip: z
						}
					});

					// create entry for zip if not in table already
					if (dbZip === null) {
						dbZip = await db.zips.create({
							zip: z
						});

						// create association between post and zip
						await db.postZips.create({
							postId: postId,
							zipId: dbZip.id
						});
					} else {
						// zip exist - check if association between post and zip exists
						let postZip = await db.postZips.findOne({
							raw: true,
							where: {
								postId: postId,
								zipId: dbZip.id
							}
						});
						if (postZip === null) {
							// create association between post and zip
							await db.postZips.create({
								postId: postId,
								zipId: dbZip.id
							});
						}
					}
				}

				// get newly updated list of post zips
				let allZips = await db.postZips.findAll({
					raw: true,
					where: {
						postId: postId
					}
				});
				if (allZips.length !== 0) {
					allZips = await db.zips.findAll({
						raw: true,
						where: {
							id: allZips.map(z => z.zipId)
						}
					});
				}

				res.status(201).json(allZips)
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}

		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error adding zips to post, please try again.",
		});
	}
}

// DELETE /posts/:postId/zips AUTH
async function removeZipsFromPost(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			zips
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(zips) && zips.length !== 0) {
				// find ids for zips given
				let dbZips = await db.zips.findAll({
					raw: true,
					where: {
						zip: zips
					}
				});
				let dbZipIds = dbZips.map((u) => u.id);

				await db.postZips.destroy({
					where: {
						zipId: dbZipIds
					}
				});

				res.sendStatus(204);
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error removing zips from post, please try again.",
		});
	}
}

// GET /posts/:postId/languages AUTH
async function getPostLanguages(req, res) {
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

		if (post !== null) {
			let languages = await db.postLanguages.findAll({
				raw: true,
				where: {
					postId: postId
				}
			});
			if (languages.length !== 0) {
				languages = await db.languages.findAll({
					raw: true,
					where: {
						id: languages.map(l => l.languageId)
					}
				});
			}
			res.status(200).json(languages);

		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting languages for post, please try again.",
		});
	}
}

// POST /posts/:postId/languages AUTH
async function addPostLanguages(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			languages
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(languages) && languages.length !== 0) {
				for (let l of languages) {
					l = l.toTitleCase()

					// check db if language exists
					let dbLang = await db.languages.findOne({
						raw: true,
						where: {
							name: l
						}
					});

					// create entry for language if not in table already
					if (dbLang === null) {
						dbLang = await db.languages.create({
							name: l
						});

						// create association between post and language
						await db.postLanguages.create({
							postId: postId,
							languageId: dbLang.id
						});
					} else {
						// language exist - check if association between post and language exists
						let userLanguage = await db.postLanguages.findOne({
							raw: true,
							where: {
								postId: postId,
								languageId: dbLang.id
							}
						});
						if (userLanguage === null) {
							// create association between post and language
							await db.postLanguages.create({
								postId: postId,
								languageId: dbLang.id
							});
						}
					}
				}

				// get newly updated list of post languages
				let allLanguages = await db.postLanguages.findAll({
					raw: true,
					where: {
						postId: postId
					}
				});
				if (allLanguages.length !== 0) {
					allLanguages = await db.languages.findAll({
						raw: true,
						where: {
							id: allLanguages.map(l => l.languageId)
						}
					});
				}

				res.status(201).json(allLanguages)
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}

		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error adding languages to post, please try again.",
		});
	}
}

// DELETE /posts/:postId/languages/:language AUTH
async function removeLanguagesFromPost(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			languages
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(languages) && languages.length !== 0) {
				// title case input
				let langs = languages.map((l) => l.toTitleCase());

				// find ids for languages given
				let dbLang = await db.languages.findAll({
					raw: true,
					where: {
						name: langs
					}
				});
				let dbLangIds = dbLang.map((u) => u.id);

				await db.postLanguages.destroy({
					where: {
						languageId: dbLangIds
					}
				});

				res.sendStatus(204);
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error removing languages from post, please try again.",
		});
	}
}

// GET /:postId/interests AUTH
async function getAllInterestedUsersForPost(req, res) {
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

		if (post !== null) {
			// lookup postInterests for all rows with postId
			let postInterests = await db.postInterests.findAll({
				raw: true,
				where: {
					postId: postId
				}
			});

			// check for at least one result
			if (postInterests.length !== 0) {
				users = await db.users.findAll({
					raw: true,
					where: {
						id: postInterests.map((e) => e.userId)
					}
				});
			}

			res.status(200).json(postInterests);
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting list of interested users for post, please try again.",
		});
	}
}

// POST /:postId/interests AUTH
async function addLoggedInUsertoInterested(req, res) {
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
				id: postId,
			},
		});

		if (post !== null) {
			// error if post owner is logged in user
			if (currentUser.id !== post.ownerId) {
				// check if association between post and user exists
				let postInterestsDB = await db.postInterests.findOne({
					raw: true,
					where: {
						postId: postId,
						userId: currentUser.id
					}
				});
				if (postInterestsDB === null) {
					// create association between post and user
					await db.postInterests.create({
						postId: postId,
						userId: currentUser.id
					})
				}

				let allInterests = await db.postInterests.findAll({
					raw: true,
					where: {
						postId: postId
					}
				});
				if (allInterests.length !== 0) {
					allInterests = await db.users.findAll({
						raw: true,
						where: {
							id: allInterests.map((e) => e.userId)
						}
					});
				}

				res.status(201).json(allInterests);
			} else {
				res.status(400).json({
					code: "Error",
					message: `Cannot add owner of post to list of interested users, please try again.`,
				});
			}

		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error adding logged in user to list of interested users, please try again.",
		});
	}
}

// DELETE /:postId/interests AUTH
async function removeLoggedInUserfromInterested(req, res) {
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
				id: postId,
			},
		});

		if (post !== null) {
			// check if logged in user is a part of interested users
			let interestedLoggedInUser = await db.postInterests.findOne({
				where: {
					postId: postId,
					userId: currentUser.id
				}
			});
			if (interestedLoggedInUser !== null) {
				await interestedLoggedInUser.destroy()

				res.sendStatus(204);
			} else {
				res.status(404).json({
					code: "Error",
					message: `Logged in user is not a part of list of interested users, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error removing logged in user from list of interested users, please try again.",
		});
	}
}

// GET /posts/:postId/categories AUTH
async function getPostCategories(req, res) {
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

		if (post !== null) {
			let categories = await db.postCategories.findAll({
				raw: true,
				where: {
					postId: postId
				}
			});
			if (categories.length !== 0) {
				categories = await db.categories.findAll({
					raw: true,
					where: {
						id: categories.map(c => c.categoryId)
					}
				});
			}
			res.status(200).json(categories);
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting categories for post, please try again.",
		});
	}
}

// POST /posts/:postId/categories AUTH
async function addPostCategories(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			categories
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(categories) && categories.length !== 0) {
				for (let c of categories) {
					c = c.toTitleCase()

					// check db if category exists
					let dbCategory = await db.categories.findOne({
						raw: true,
						where: {
							name: c
						}
					});

					// create entry for category if not in table already
					if (dbCategory === null) {
						dbCategory = await db.categories.create({
							name: c
						});

						// create association between post and category
						await db.postCategories.create({
							postId: postId,
							categoryId: dbCategory.id
						});
					} else {
						// zip exist - check if association between post and category exists
						let postZip = await db.postCategories.findOne({
							raw: true,
							where: {
								postId: postId,
								categoryId: dbCategory.id
							}
						});
						if (postZip === null) {
							// create association between post and category
							await db.postCategories.create({
								postId: postId,
								categoryId: dbCategory.id
							});
						}
					}
				}

				// get newly updated list of post categories
				let allCategories = await db.postCategories.findAll({
					raw: true,
					where: {
						postId: postId
					}
				});
				if (allCategories.length !== 0) {
					allCategories = await db.categories.findAll({
						raw: true,
						where: {
							id: allCategories.map(c => c.categoryId)
						}
					});
				}

				res.status(201).json(allCategories)
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error adding categories for post, please try again.",
		});
	}
}

// DELETE /posts/:postId/categories AUTH
async function removeCategoriesFromPost(req, res) {
	try {
		const {
			postId
		} = req.params;
		const {
			categories
		} = req.body;

		let post = await db.posts.findOne({
			raw: true,
			where: {
				id: postId,
			},
		});

		if (post !== null) {
			// ensure non-empty input
			if (Array.isArray(categories) && categories.length !== 0) {
				let titleCaseCategories = categories.map((c) => c.toTitleCase());

				// find ids for categories given
				let dbCategories = await db.categories.findAll({
					raw: true,
					where: {
						name: titleCaseCategories
					}
				});
				let dbCategoryIds = dbCategories.map((u) => u.id);

				await db.postCategories.destroy({
					where: {
						categoryId: dbCategoryIds
					}
				});

				res.sendStatus(204);
			} else {
				res.status(400).json({
					code: "Error",
					message: `Input must consist of non-empty array, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Post ${postId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error removing categories from post, please try again.",
		});
	}
}

// GET /posts/filter AUTH
async function getPostsBasedOnFilter(req, res) {
	try {
		res.send("Work in progress");

	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting posts based on filter, please try again.",
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
	getPostZips: getPostZips,
	addPostZips: addPostZips,
	removeZipsFromPost: removeZipsFromPost,
	getPostLanguages: getPostLanguages,
	addPostLanguages: addPostLanguages,
	removeLanguagesFromPost: removeLanguagesFromPost,
	getAllInterestedUsersForPost: getAllInterestedUsersForPost,
	addLoggedInUsertoInterested: addLoggedInUsertoInterested,
	removeLoggedInUserfromInterested: removeLoggedInUserfromInterested,
	getPostCategories: getPostCategories,
	addPostCategories: addPostCategories,
	removeCategoriesFromPost: removeCategoriesFromPost,
	getPostsBasedOnFilter: getPostsBasedOnFilter
};