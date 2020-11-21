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

		var user = await db.users.findOne({
			raw: true,
			where: {
				id: userId,
			},
		});

		user = await standardizeUserObject(user);

		res.status(200).json(user);
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

		// ensure non-empty input
		if (typeof zips === "object" && zips.length !== 0) {
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
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error adding zips for user, please try again.`,
		});
	}
}

// DELETE /users/:userId/zips/:zip AUTH
async function removeZipFromUser(req, res) {
	try {
		const {
			userId,
			zip
		} = req.params;

		// check if valid zip
		let zipObj = await db.zips.findOne({
			raw: true,
			where: {
				zip: zip
			}
		});
		if (zipObj !== null) {
			// check if association exists between user and zip
			let userZip = await db.userZips.findOne({
				where: {
					userId: userId,
					zipId: zipObj.id
				}
			});

			if (userZip !== null) {
				await userZip.destroy();
				res.sendStatus(204);
			} else {
				res.status(404).json({
					code: "Error",
					message: `Zip ${zip} not found for user ${userId}, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `Zip ${zip} not found, please try again.`,
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

		// ensure non-empty input
		if (typeof languages === "object" && languages.length !== 0) {
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
	} catch (err) {
		console.log(err);
		res.status(500).json({
			code: "Error",
			message: `Error adding languages for user, please try again.`,
		});
	}
}

// DELETE /users/:userId/languages/:language AUTH
async function removeLanguageFromUser(req, res) {
	try {
		const {
			userId,
			language
		} = req.params;

		const lang = language.toTitleCase();

		// check if valid language
		let languageObj = await db.languages.findOne({
			raw: true,
			where: {
				name: lang
			}
		});
		if (languageObj !== null) {
			// check if association exists between user and language
			let userLang = await db.userLanguages.findOne({
				where: {
					userId: userId,
					languageId: languageObj.id
				}
			});

			if (userLang !== null) {
				await userLang.destroy();
				res.sendStatus(204);
			} else {
				res.status(404).json({
					code: "Error",
					message: `${lang} not found for user ${userId}, please try again.`,
				});
			}
		} else {
			res.status(404).json({
				code: "Error",
				message: `${lang} not found, please try again.`,
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

module.exports = {
	getAllUsers: getAllUsers,
	getLoggedInUser: getLoggedInUser,
	getUserById: getUserById,
	editLoggedInUser: editLoggedInUser,
	deleteLoggedInUser: deleteLoggedInUser,
	getUserZips: getUserZips,
	addUserZips: addUserZips,
	removeZipFromUser: removeZipFromUser,
	getUserLanguages: getUserLanguages,
	addUserLanguages: addUserLanguages,
	removeLanguageFromUser: removeLanguageFromUser
};