const db = require("../models");

const messageController = {
    createMessage: createMessage,
};


async function createMessage(req, res) {
    try {
        const {
            userId,
            convoId
        } = req.params;

        const {
            body
        } = req.body;
        const dateCreated = new Date();

        const newMessage = {
            userId,
            convoId,
            body,
        };

        let message = await db.messages.create(newMessage);

        res.status(201).json(message)
    } catch (err) {
        console.log(err)
    }
}

module.exports = messageController;