const db = require("../models");
const decodeJwt = require("../utils/decodeJwt");

const postInterestsController = {
    getPostInterestByPostId: getPostInterestByPostId,
    addLoggedInUsertoInterested: addLoggedInUsertoInterested,
    removeLoggedInUsertoInterested: removeLoggedInUsertoInterested
};

async function getPostInterestByPostId(req, res) {
    try {
        const {
            postId
        } = req.params
        let postInterests = await db.postInterests.findAll({
            raw: true,
            where: {
                postId: postId
            }
        })
        let users = await Promise.all(postInterests.map((e) => e.userId).map(async (u) => await db.users.findOne({
            raw: true,
            where: {
                id: u
            }
        })))
        res.status(200).json(users)
    } catch (err) {
        console.log(err)
    }
}

async function addLoggedInUsertoInterested(req, res) {
    try {
        let decodedJwt = await decodeJwt(req.headers);
        let currentUser = await db.users.findOne({
            raw: true,
            where: {
                email: decodedJwt.email
            },
        });

        const {
            postId
        } = req.params
        let postInterest = await db.postInterests.create({
            postId: postId,
            userId: currentUser.id
        })
        res.status(201).json(postInterest)
    } catch (err) {
        console.log(err)
    }
}

async function removeLoggedInUsertoInterested(req, res) {
    try {
        let decodedJwt = await decodeJwt(req.headers);
        let currentUser = await db.users.findOne({
            raw: true,
            where: {
                email: decodedJwt.email
            },
        });

        const {
            postId
        } = req.params
        await db.postInterests.destroy({
            where: {
                postId: postId,
                userId: currentUser.id
            }
        })
        res.status(200).json({
            code: "Success",
        });
    } catch (err) {
        console.log(err)
    }
}

module.exports = postInterestsController;