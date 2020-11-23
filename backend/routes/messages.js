const express = require("express");
const router = express.Router();
const messageController = require("../controllers/messages");

router.route("/:userId/:convoId").post(messageController.createMessage);
router.route("/:convoId").get(messageController.getAllMessagesOfConvo)
router.route("/x/:convoId/:nummsgs").get(messageController.getXMessagesOfConvo)
router.route("/:messageId").delete(messageController.deleteMessage);
router.route("/:messageId").put(messageController.editMessage);
module.exports = router;