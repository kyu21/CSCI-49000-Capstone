const express = require("express");
const router = express.Router();
const postController = require("../controllers/posts");

router.route("/").get(postController.getAllPosts);
router.route("/:userId").post(postController.createPost);
router.route("/:postId").get(postController.getPostById);

module.exports = router;