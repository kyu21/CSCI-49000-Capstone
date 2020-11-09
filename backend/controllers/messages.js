const db = require("../models");

const messageController = {
    createMessage: createMessage,
    editMessage: editMessage,
    deleteMessage: deleteMessage,
    getAllMessagesOfConvo: getAllMessagesOfConvo,
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

async function getAllMessagesOfConvo(req, res, next) {
    try {
        const {
            convoId,
        } = req.params;

        const allConvoMessages = await db.messages.findAll({
            where: {
                convoId: convoId
            }
        });

        res.status(200).json(allConvoMessages)

    } catch (err) {
        console.log(err);
        res.sendStatus(500);
    }
}


async function editMessage(req, res) {
    try {
        const {
            messageId,
        } = req.params;

        const {
            body
        } = req.body;

        let newmsg = body;

        await db.messages.update(
            {body: newmsg},
            {where: {id: messageId}}
        )

        res.sendStatus(200);
    } catch (err) {
        console.log(err)
    }
}

//does not check if message is owned by the user (handle this in frontend)
async function deleteMessage(req, res, next) {
    try {
        const {
            messageId,
        } = req.params;

        let msg = messageId;

        db.messages.destroy({ 
            where: {id: msg}
        }).then((result) => {
            res.sendStatus(200)
        })
        .catch((err) => {
            console.log(err)
            res.sendStatus(500)
        })

    } catch (err) {
        console.log(err);
    }
}

module.exports = messageController;