const express = require("express");
const router = express.Router();
const userPostsController = require("../controllers/userPosts");

router.route("/:userId").get(userPostsController.getAllPostsForUser);
router.route("/:userId").post(userPostsController.createPost);

module.exports = router;