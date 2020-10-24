const express = require("express");
const router = express.Router();
const convoController = require("../controllers/convos");

//router.route("/").get(postController.getAllPosts);
router.route("/:userId").post(convoController.createConvo);
router.route("/:userId").get(convoController.getAllConvosForUser);
//router.route("/:postId").get(postController.getPostById);

module.exports = router;