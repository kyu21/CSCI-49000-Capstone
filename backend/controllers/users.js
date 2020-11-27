const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");
var bcrypt = require("bcrypt");
const saltRounds = 10;

require('@gouch/to-title-case');

const {
	standardizeUserObject,
	cascadeDeleteUser
} = require("../utils/standardize")

// GET /users AUTH
async function getAllUsers(req, res) {
	try {
		let users = await db.users.findAll({
			raw: true
		})

		users = await Promise.all(
			users.map(
				async (e) =>
					await standardizeUserObject(e)
			)
		);

		res.status(200).json(users);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting all users, please try again.",
		});
	}
}

// GET /users/me AUTH
async function getLoggedInUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		user = await standardizeUserObject(currentUser);
		res.status(200).json(user);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: "Error getting logged in user, please try again.",
		});
	}
}

// GET /users/:userId AUTH
async function getUserById(req, res) {
	try {
		const {
			userId
		} = req.params;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
			user = await standardizeUserObject(user);

			res.status(200).json(user);
		} else {
			res.status(404).json({
				code: "Error",
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error getting user, please try again.`,
		});
	}
}

// PUT /users AUTH
async function editLoggedInUser(req, res) {
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

		let invalidNewEmail = false;
		let invalidInput = false;

		let newInfo = {};
		for (let key in req.body) {
			let val = req.body[key]
			if (typeof val === "string" && val.length > 0) {
				if (validKeys.indexOf(key) >= 0) {
					newInfo[key] = val;

					// no duplicate emails
					if (key === "email" && newInfo["email"] !== currentUser.email) {
						let newEmail = newInfo["email"];
						let user = await db.users.findOne({
							raw: true,
							where: {
								email: newEmail
							}
						});

						if (user !== null) {
							invalidNewEmail = true;
							break
						}
					}

					// need to rehash password
					if (key === "password") {
						let hashedPassword = await bcrypt.hash(
							req.body[key],
							saltRounds
						);
						newInfo[key] = hashedPassword;
					}
				}
			} else {
				invalidInput = true;
			}

		}

		if (invalidNewEmail) {
			res.status(403).json({
				code: "Error",
				message: `An account is already registered with ${newInfo["email"]}, please try again.`,
			});
		} else if (invalidInput) {
			res.status(400).json({
				code: "Error",
				message: `Input must consist of non-empty strings, please try again.`,
			});
		} else {
			let [_, users] = await db.users.update(newInfo, {
				where: {
					id: currentUser.id
				},
				returning: true,
				raw: true,
			});

			let editedUser = await standardizeUserObject(users[0]);

			res.status(200).json(editedUser);
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error editing user, please try again.`,
		});
	}
}

// DELETE /users AUTH
async function deleteLoggedInUser(req, res) {
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
		await cascadeDeleteUser(currentUser.id);

		res.sendStatus(204);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error deleting user, please try again.`,
		});
	}
}

// GET /users/:userId/zips AUTH
async function getUserZips(req, res) {
	try {
		const {
			userId
		} = req.params;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
			let zips = await db.userZips.findAll({
				raw: true,
				where: {
					userId: userId
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error getting zips for user, please try again.`,
		});
	}
}

// POST /users/:userId/zips AUTH
async function addUserZips(req, res) {
	try {
		const {
			userId
		} = req.params;
		const {
			zips
		} = req.body;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
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

						// create association between user and zip
						await db.userZips.create({
							userId: userId,
							zipId: dbZip.id
						});
					} else {
						// zip exist - check if association between user and zip exists
						let userZip = await db.userZips.findOne({
							raw: true,
							where: {
								userId: userId,
								zipId: dbZip.id
							}
						});
						if (userZip === null) {
							// create association between user and zip
							await db.userZips.create({
								userId: userId,
								zipId: dbZip.id
							});
						}
					}
				}

				// get newly updated list of user zips
				let allZips = await db.userZips.findAll({
					raw: true,
					where: {
						userId: userId
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error adding zips for user, please try again.`,
		});
	}
}

// DELETE /users/:userId/zips AUTH
async function removeZipsFromUser(req, res) {
	try {
		const {
			userId
		} = req.params;

		const {
			zips
		} = req.body;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
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

				await db.userZips.destroy({
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error removing zip for user, please try again.`,
		});
	}
}

// GET /users/:userId/languages AUTH
async function getUserLanguages(req, res) {
	try {
		const {
			userId
		} = req.params;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
			let languages = await db.userLanguages.findAll({
				raw: true,
				where: {
					userId: userId
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error getting languages for user, please try again.`,
		});
	}
}

// POST /users/:userId/languages AUTH
async function addUserLanguages(req, res) {
	try {
		const {
			userId
		} = req.params;
		const {
			languages
		} = req.body;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
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

						// create association between user and language
						await db.userLanguages.create({
							userId: userId,
							languageId: dbLang.id
						});
					} else {
						// language exist - check if association between user and language exists
						let userLanguage = await db.userLanguages.findOne({
							raw: true,
							where: {
								userId: userId,
								languageId: dbLang.id
							}
						});
						if (userLanguage === null) {
							// create association between user and language
							await db.userLanguages.create({
								userId: userId,
								languageId: dbLang.id
							});
						}
					}
				}

				// get newly updated list of user languages
				let allLanguages = await db.userLanguages.findAll({
					raw: true,
					where: {
						userId: userId
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error adding languages for user, please try again.`,
		});
	}
}

// DELETE /users/:userId/languages/ AUTH
async function removeLanguagesFromUser(req, res) {
	try {
		const {
			userId
		} = req.params;
		const {
			languages
		} = req.body;

		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		if (user !== null) {
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

				await db.userLanguages.destroy({
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
				message: `User ${userId} not found, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error removing language for user, please try again.`,
		});
	}
}

// GET /users/convos AUTH
async function getUserConvos(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		// get convos
		let convos = await db.userConvos.findAll({
			raw: true,
			where: {
				userId: currentUser.id
			},
			order: [
				['createdAt', 'DESC']
			]
		});

		res.status(200).json(convos);
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error getting conversations for the logged in user, please try again.`,
		});
	}
}

// GET /users/convos/:convoId AUTH
async function getConvoByConvoId(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		const {
			convoId
		} = req.params;

		// check if logged in user is a part of this specific convo
		let userConvo = await db.userConvos.findOne({
			raw: true,
			where: {
				userId: currentUser.id,
				convoId: convoId
			}
		});
		if (userConvo !== null) {
			res.status(200).json(userConvo);
		} else {
			res.status(404).json({
				code: "Error",
				message: `Convo ${convoId} is not found for the logged in user, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error getting this converastion for the logged in user, please try again.`,
		});
	}
}

// POST /users/convos/:userId AUTH
async function createConvoWithUser(req, res) {
	try {
		let decodedJwt = await decodeJwt(req.headers);
		let currentUser = await db.users.findOne({
			raw: true,
			where: {
				email: decodedJwt.email
			},
		});

		const {
			userId
		} = req.params;

		// check if valid user
		let user = await db.users.findOne({
			raw: true,
			where: {
				id: userId
			}
		});
		if (user !== null) {
			// check if convo already exists between 2 users
			let userConvos = await db.userConvos.findAll({
				raw: true,
				where: {
					userId: userId
				}
			});
			userConvos = userConvos.map((e) => e.convoId);

			let userConvosLogged = await db.userConvos.findAll({
				raw: true,
				where: {
					userId: currentUser.id
				}
			});
			userConvosLogged = userConvosLogged.map((e) => e.convoId);

			let commonConvoExists = userConvos.some(e => userConvosLogged.includes(e));

			if (!commonConvoExists) {
				// create convo
				let convo = await db.convos.create({
					userId: currentUser.id
				});
				convo = convo.get({
					plain: true
				});

				await db.userConvos.bulkCreate([{
					userId: currentUser.id,
					convoId: convo.id
				}, {
					userId: userId,
					convoId: convo.id
				}]);

				res.status(201).json(convo);
			} else {
				res.status(400).json({
					code: "Error",
					message: `Conversation already exists between User ${currentUser.id} and User ${userId}, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `User ${userId} does not exist, please try again.`,
			});
		}
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error creating a conversation, please try again.`,
		});
	}
}

module.exports = {
	getAllUsers: getAllUsers,
	getLoggedInUser: getLoggedInUser,
	getUserById: getUserById,
	editLoggedInUser: editLoggedInUser,
	deleteLoggedInUser: deleteLoggedInUser,
	getUserZips: getUserZips,
	addUserZips: addUserZips,
	removeZipsFromUser: removeZipsFromUser,
	getUserLanguages: getUserLanguages,
	addUserLanguages: addUserLanguages,
	removeLanguagesFromUser: removeLanguagesFromUser,
	getUserConvos: getUserConvos,
	getConvoByConvoId: getConvoByConvoId,
	createConvoWithUser: createConvoWithUser
};