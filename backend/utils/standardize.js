const {
    Op
} = require("sequelize");

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

        // convos
        const allConvosInfo = await db.userConvos.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });

        user["zips"] = allZipsInfo;
        user["languages"] = allLanguagesInfo;
        user["posts"] = allPostsInfo;
        user["interests"] = allInterestsInfo;
        user["convos"] = allConvosInfo;

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


async function standardizeConvoObject(convo) {
    try {
        const convoId = convo.id;

        // change convo userId to ownerId
        Object.defineProperty(convo, "ownerId",
            Object.getOwnPropertyDescriptor(convo, "userId"));
        delete convo["userId"];

        // get participants of convo
        const participants = await db.userConvos.findAll({
            raw: true,
            where: {
                convoId: convoId
            }
        });
        const participantsInfo = await db.users.findAll({
            raw: true,
            where: {
                id: participants.map(e => e.userId)
            }
        });

        // get messages of convo
        const messages = await db.messages.findAll({
            raw: true,
            where: {
                convoId: convoId
            },
            order: [
                ['createdAt', 'ASC']
            ]
        });

        convo["participants"] = participantsInfo;
        convo["messages"] = messages;

        return convo;
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

        // delete any convo and messages user is part of
        const userConvos = await db.userConvos.findAll({
            raw: true,
            where: {
                userId: userId
            }
        });
        const toBeDeletedConvoIds = userConvos.map(u => u.convoId)

        await db.userConvos.destroy({
            raw: true,
            where: {
                [Op.or]: [{
                        userId: userId
                    },
                    {
                        convoId: toBeDeletedConvoIds
                    }
                ]
            }
        });
        await db.messages.destroy({
            raw: true,
            where: {
                [Op.or]: [{
                        userId: userId
                    },
                    {
                        convoId: toBeDeletedConvoIds
                    }
                ]
            }
        })

        // delete any convo user made
        await db.convos.destroy({
            where: {
                [Op.or]: [{
                        userId: userId
                    },
                    {
                        id: toBeDeletedConvoIds
                    }
                ]
            }
        });

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

async function cascadeDeleteConvo(convoId) {
    try {
        await db.convos.destroy({
            where: {
                id: convoId
            }
        });

        await db.userConvos.destroy({
            where: {
                convoId: convoId
            }
        });

        await db.messages.destroy({
            where: {
                convoId: convoId
            }
        });
    } catch (err) {
        console.log(err);
    }
}

async function cascadeDeleteZip(zipId) {
    try {
        // delete any associations with users
        await db.userZips.destroy({
            where: {
                zipId: zipId
            }
        });

        // delete any associations with posts
        await db.postZips.destroy({
            where: {
                zipId: zipId
            }
        });
    } catch (err) {
        console.log(err);
    }
}

async function cascadeDeleteLanguage(languageId) {
    try {
        // delete any associations with users
        await db.userLanguages.destroy({
            where: {
                languageId: languageId
            }
        });

        // delete any associations with posts
        await db.postLanguages.destroy({
            where: {
                languageId: languageId
            }
        });
    } catch (err) {
        console.log(err);
    }
}

async function cascadeDeleteCategory(categoryId) {
    try {
        // delete any associations with posts
        await db.postCategories.destroy({
            where: {
                categoryId: categoryId
            }
        });
    } catch (err) {
        console.log(err);
    }
}

module.exports = {
    standardizeUserObject: standardizeUserObject,
    standardizePostObject: standardizePostObject,
    standardizeConvoObject: standardizeConvoObject,
    cascadeDeleteUser: cascadeDeleteUser,
    cascadeDeletePost: cascadeDeletePost,
    cascadeDeleteConvo: cascadeDeleteConvo,
    cascadeDeleteZip: cascadeDeleteZip,
    cascadeDeleteLanguage: cascadeDeleteLanguage,
    cascadeDeleteCategory: cascadeDeleteCategory
};