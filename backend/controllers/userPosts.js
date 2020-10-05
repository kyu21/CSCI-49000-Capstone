const db = require("../models");
const Op = db.Sequelize.Op;

const userPostsController = {
    getAllPostsForUser: getAllPostsForUser,
    createPost: createPost
}

async function getAllPostsForUser(req, res, next) {
    try {
        const {
            userId
        } = req.params;
        const allUserPosts = await db.userPosts.findAll({
            where: {
                userId: userId
            }
        });

        const allPosts = await Promise.all(
            allUserPosts.map(async (postEle) => (
                await db.posts.findOne({
                    where: {
                        id: postEle.postId
                    }
                })
            ))
        );

        res.status(200).json(allPosts)

    } catch (err) {
        console.log(err);
    }
}

async function createPost(req, res, next) {
    try {
        const {
            userId
        } = req.params

        const {
            title,
            description
        } = req.body

        const dateCreated = new Date();

        var newPost = {
            title,
            description,
            dateCreated
        }

        await db.posts.create(newPost)
            .then(p => db.userPosts.create({
                userId: userId,
                postId: p.id
            }))

        res.status(201).json(newPost)

    } catch (err) {
        console.log(err);
    }
}

module.exports = userPostsController;