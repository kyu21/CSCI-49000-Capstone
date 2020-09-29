const db = require("../models");
const Op = db.Sequelize.Op;

const userController = {
    getAllUsers: getAllUsers,
    createUser: createUser
};

async function getAllUsers(req, res, next) {
    try {
        const users = await db.users.findAll();
        res.status(200).json(users);
        console.log("attempting to find users");
    } catch (err) {
        console.log(err);
    }
}

async function createUser(req, res, next) {
    try {
        let newUser = req.body;
        const userExists = await db.users.findOne({
            where: {
                name: newUser.name
            },
        });
        if (!userExists) {
            await db.users.create(newUser);
            res.status(200).json({
                code: "Success",
                message: "User created"
            });
        } else {
            res.status(401).json({
                code: "error",
                message: "Email exists."
            });
        }
    } catch (err) {
        console.log(err);
        res.status(401).json({
            code: "error",
            message: "Error with creating account. Please retry.",
        });
    }
}

module.exports = userController;