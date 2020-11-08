const db = require("../models");

const controller = {
    cleanup: cleanup
}

async function cleanup(req, res) {
    try {
        const users = await db.users.findAll({raw: true})
        const userIds = users.map((u) => u.id)

        // userZips
        let userZips = await db.userZips.findAll({raw: true})
        userZips = userZips.filter( (e) => userIds.indexOf(e.userId) === -1).map( (e) => e.id)
        await db.userZips.destroy({where: {id: userZips}})

        // userLanguages
        let userLanguages = await db.userLanguages.findAll({raw: true})
        userLanguages = userLanguages.filter( (e) => userIds.indexOf(e.userId) === -1).map( (e) => e.id)
        await db.userLanguages.destroy({where: {id: userLanguages}})

        // posts
        let posts = await db.posts.findAll({raw: true})
        posts = posts.filter( (e) => userIds.indexOf(e.ownerId) === -1).map( (e) => e.id)
        // await db.userLanguages.destroy({where: {id: userLanguages}})

        res.send(posts)
    } catch (err) {
        console.log(err)
    }
}

module.exports = controller;