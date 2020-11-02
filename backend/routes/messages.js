const express = require("express");
const router = express.Router();
const messageController = require("../controllers/messages");

router.route("/:userId/:convoId").post(messageController.createMessage);

module.exports = router;