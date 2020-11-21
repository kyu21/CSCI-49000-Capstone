const db = require("../models");

const decodeJwt = require("../utils/decodeJwt");
var bcrypt = require("bcrypt");
const saltRounds = 10;

const {
	standardizeUserObject,
	cascadeDeleteUser
} = require("../utils/standardize")

const userController = {
	getAllUsers: getAllUsers,
	getLoggedInUser: getLoggedInUser,
	getUserById: getUserById,
	editLoggedInUser: editLoggedInUser,
	deleteLoggedInUser: deleteLoggedInUser
};

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
			message: `Error getting user ${userId}, please try again.`,
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
			message: `Error editing user ${userId}, please try again.`,
		});
	}
}

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
			message: `Error deleting user ${currentUser.id}, please try again.`,
		});
	}
}

module.exports = userController;