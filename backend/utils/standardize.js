const db = require("../models");

async function standardizeUserObject(user) {
    try {
        const userId = user.id;

        // zips
        const allZips = await db.userZips.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allZipsInfo = await db.zips.findAll({
            raw: true,
            where: {
                id: allZips.map(z => z.zipId)
            }
        })

        // languages
        const allLanguages = await db.userLanguages.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allLanguagesInfo = await db.languages.findAll({
            raw: true,
            where: {
                id: allLanguages.map(l => l.languageId)
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
        const allInterests = await db.postInterests.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const allInterestsInfo = await db.posts.findAll({
            raw: true,
            where: {
                id: allInterests.map(p => p.postId)
            }
        });

        user["zips"] = allZipsInfo;
        user["languages"] = allLanguagesInfo;
        user["posts"] = allPostsInfo;
        user["interests"] = allInterestsInfo;

        return user;
    } catch (err) {
        console.log(err);
    }
}

async function standardizePostObject(post) {
    try {
        const postId = post.id;
        const ownerId = post.ownerId;

        // owner
        const owner = await db.users.findOne({
            raw: true,
            where: {
                id: ownerId
            }
        });

        // zips
        const allZips = await db.postZips.findAll({
            raw: true,
            where: {
                postId: postId
            }
        });
        const allZipsInfo = await db.zips.findAll({
            raw: true,
            where: {
                id: allZips.map(z => z.zipId)
            }
        });

        // languages
        const allLanguages = await db.postLanguages.findAll({
            raw: true,
            where: {
                postId: postId
            }
        });
        const allLanguagesInfo = await db.languages.findAll({
            raw: true,
            where: {
                id: allLanguages.map(l => l.languageId)
            }
        });

        // interests
        const allInterests = await db.postInterests.findAll({
            raw: true,
            where: {
                postId: postId
            }
        });
        const allInterestsInfo = await db.users.findAll({
            raw: true,
            where: {
                id: allInterests.map(u => u.userId)
            }
        });

        // categories
        const allCategories = await db.postCategories.findAll({
            raw: true,
            where: {
                postId: postId
            }
        });
        const allCategoriesInfo = await db.categories.findAll({
            raw: true,
            where: {
                id: allCategories.map(c => c.categoryId)
            }
        });

        post["owner"] = owner;
        post["zips"] = allZipsInfo;
        post["languages"] = allLanguagesInfo;
        post["interests"] = allInterestsInfo;
        post["categories"] = allCategoriesInfo;

        return post;
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
    standardizePostObject: standardizePostObject,
    cascadeDeleteUser: cascadeDeleteUser,
    cascadeDeletePost: cascadeDeletePost
};