const db = require("../models");

async function standardizeUserObject(userId, user) {
    try {
        // zips
        const allUserZips = await db.userZips.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allZipsInfo = await db.zips.findAll({
            raw: true,
            where: {
                id: allUserZips.map(z => z.zipId)
            }
        })

        // languages
        const allUserLanguages = await db.userLanguages.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allLanguagesInfo = await db.languages.findAll({
            raw: true,
            where: {
                id: allUserLanguages.map(l => l.languageId)
            }
        });

        // posts
        const allPostsInfo = await db.posts.findAll({
            raw: true,
            where: {
                ownerId: userId
            }
        });

        // post interests
        const allUserInterests = await db.postInterests.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allInterestsInfo = await db.posts.findAll({
            raw: true,
            where: {
                id: allUserInterests.map(p => p.postId)
            }
        });

        user["zips"] = allZipsInfo
        user["languages"] = allLanguagesInfo
        user["posts"] = allPostsInfo
        user["interests"] = allInterestsInfo
    } catch (err) {
        console.log(err);
    }
}

module.exports = {
    standardizeUserObject: standardizeUserObject
};