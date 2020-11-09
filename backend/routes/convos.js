const express = require("express");
const router = express.Router();
const convoController = require("../controllers/convos");

//router.route("/").get(postController.getAllPosts);
router.route("/:userId").post(convoController.createConvo);
router.route("/:userId").get(convoController.getAllConvosForUser);
router.route("/:userId/:convoId").put(convoController.leaveConvo);
router.route("/:convoId").delete(convoController.deleteConvo);

module.exports = router;