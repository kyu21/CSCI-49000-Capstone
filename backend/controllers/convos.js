const db = require("../models");

const convoController = {
    createConvo: createConvo,
    getAllConvosForUser: getAllConvosForUser,
};

//takes a list of users and makes a new convo with them as participants
//todo: check if a convo is a dupe (has same participants)
async function createConvo(req, res) {
    try {
        const {
            userId,
        } = req.params;

        // const {
        //     users
        // } = req.body;
        let users = req.body.users;
        users.push(userId) //the creator is also a participant

        const dateCreated = new Date();

        const newConvo = {
            userId
        };

        let convo = await db.convos.create(newConvo);

        //for each participant, add a row in userConvos
        let promises = []

        for (let i = 0; i < users.length; i++){
            let newpromise = db.userConvos.create({
                userId: users[i],
                convoId: convo.id
            });
            promises.push(newpromise)
        }

        return Promise.all(promises).then((convos) => {
            res.status(201).json(convos)     
        })
        .catch(function (err){
            console.log(err);
        })
        
    } catch (err) {
        console.log(err)
    }
}

async function getAllConvosForUser(req, res, next) {
    try {
        const {
            userId
        } = req.params;
        const allUserConvos = await db.userConvos.findAll({
            where: {
                userId: userId
            }
        });

        const allConvos = await Promise.all(
            allUserConvos.map(async (convoEle) => (
                await db.convos.findOne({
                    where: {
                        id: convoEle.convoId
                    }
                })
            ))
        );

        res.status(200).json(allConvos)

    } catch (err) {
        console.log(err);
    }
}

module.exports = convoController;