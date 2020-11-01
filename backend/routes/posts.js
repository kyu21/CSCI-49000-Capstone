const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const postController = require("../controllers/posts");

router.route("/").get(auth, postController.getAllPosts);
router.route("/me").get(auth, postController.getLoggedInUserPosts);
router.route("/").post(auth, postController.createPost);
router.route("/:postId").get(auth, postController.getPostById);
router.route("/:postId").put(auth, postController.editPost);
router.route("/:postId").delete(auth, postController.deletePost);

module.exports = router;
