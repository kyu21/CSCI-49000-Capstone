const db = require("../models");
const User = db.users;
const Op = db.Sequelize.Op;

const userController = {
    getAllUsers: getAllUsers
};

async function getAllUsers(req, res, next) {
    try {
        const users = await User.findAll();
        console.log(users)
        res.status(200).json(users);
        console.log("attempting to find users");
    } catch (err) {
        console.log(err);
    }
}

module.exports = userController;