const db = require("../models");

async function standardizeUserObject(user) {
    try {
        const userId = user.id;
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

        return user
    } catch (err) {
        console.log(err);
    }
}

async function cascadeDeleteUser(userId) {
    try {
        // delete any associations with zips
        await db.userZips.destroy({
            where: {
                userId: userId
            }
        });

        // delete any associations with languages
        await db.userLanguages.destroy({
            where: {
                userId: userId
            }
        })

        // delete any posts user is interested in
        await db.postInterests.destroy({
            where: {
                userId: userId
            }
        })

        // delete any posts user made
        const posts = await db.posts.findAll({
            raw: true,
            where: {
                ownerId: userId
            }
        });
        if (posts.length !== 0) {
            await Promise.all(
                posts.forEach(
                    async (p) =>
                        await cascadeDeletePost(p.id)
                )
            );
        }
    } catch (err) {
        console.log(err);
    }
}

async function cascadeDeletePost(postId) {
    try {
        // delete any associations with zips
        await db.postZips.destroy({
            where: {
                postId: postId
            }
        });

        // delete any associations with languages
        await db.postLanguages.destroy({
            where: {
                postId: postId
            }
        });

        // delete any associations with categories
        await db.postCategories.destroy({
            where: {
                postId: postId
            }
        });

        // delete any associations with interests
        await db.postInterests.destroy({
            where: {
                postId: postId
            }
        });
    } catch (err) {
        console.log(err);
    }
}

module.exports = {
    standardizeUserObject: standardizeUserObject,
    cascadeDeleteUser: cascadeDeleteUser,
    cascadeDeletePost: cascadeDeletePost
};