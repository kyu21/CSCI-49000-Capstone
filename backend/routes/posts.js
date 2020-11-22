const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const controller = require("../controllers/posts");

router.route("/").get(auth, controller.getAllPosts);
router.route("/me").get(auth, controller.getLoggedInUserPosts);
router.route("/:postId").get(auth, controller.getPostById);
router.route("/").post(auth, controller.createPost);
router.route("/:postId").put(auth, controller.editPost);
router.route("/:postId").delete(auth, controller.deletePost);

// zips

// languages

// interests

// categories

// filter

module.exports = router;