const db = require("../models");
const Op = db.Sequelize.Op;

const userZipsController = {
    getAllZipsForUser: getAllZipsForUser
}

async function getAllZipsForUser(req, res, next) {
    try {
        const {
            userId
        } = req.params;
        const allUserZips = await db.userZips.findAll({
            where: {
                userId: userId
            }
        });

        const allZipsInfo = await Promise.all(
            allUserZips.map(async (zipEle) => (
                await db.zips.findOne({
                    where: {
                        id: zipEle.zipId
                    }
                })
            ))
        );

        res.status(200).json(allZipsInfo)

    } catch (err) {
        console.log(err);
    }
}

module.exports = userZipsController;