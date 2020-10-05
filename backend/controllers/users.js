const db = require("../models");
const Op = db.Sequelize.Op;

const userController = {
    getAllUsers: getAllUsers,
    createUser: createUser,
    getUserById: getUserById
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

async function getUserById(req, res, next) {
    try {
        const {
            userId
        } = req.params;

        var user = await db.users.findOne({
            raw: true,
            where: {
                id: userId
            }
        });

        // zips
        const allUserZips = await db.userZips.findAll({
            where: {
                userId: userId
            }
        });
        const allZipsInfo = await Promise.all(
            allUserZips.map(async (zipEle) => {
                var zip = await db.zips.findOne({
                    raw: true,
                    where: {
                        id: zipEle.zipId
                    }
                });
                delete zip.id
                return zip
            })
        );

        // languages
        const allUserLang = await db.userLanguages.findAll({
            where: {
                userId: userId
            }
        });
        const allLangInfo = await Promise.all(
            allUserLang.map(async (langEle) => {
                var lang = await db.languages.findOne({
                    raw: true,
                    where: {
                        id: langEle.languageId
                    }
                });
                delete lang.id
                return lang
            })
        );

        user["zips"] = allZipsInfo
        user["languages"] = allLangInfo

        res.status(200).json(user)
    } catch (err) {
        console.log(err);
    }
}

module.exports = userController;