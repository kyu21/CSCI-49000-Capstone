const db = require("../models");
const Op = db.Sequelize.Op;

const userLanguagesController = {
    getAllLanguagesForUser: getAllLanguagesForUser
}

async function getAllLanguagesForUser(req, res, next) {
    try {
        const {
            userId
        } = req.params;
        const allUserLang = await db.userLanguages.findAll({
            where: {
                userId: userId
            }
        });

        const allLangInfo = await Promise.all(
            allUserLang.map(async (langEle) => (
                await db.languages.findOne({
                    where: {
                        id: langEle.languageId
                    }
                })
            ))
        );

        res.status(200).json(allLangInfo)

    } catch (err) {
        console.log(err);
    }
}

module.exports = userLanguagesController;