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
router.route("/:postId/zips").get(auth, controller.getPostZips);
router.route("/:postId/zips").post(auth, controller.addPostZips);
router.route("/:postId/zips/:zip").delete(auth, controller.removeZipFromPost);

// languages
router.route("/:postId/languages").get(auth, controller.getPostLanguages);
router.route("/:postId/languages").post(auth, controller.addPostLanguages);
router.route("/:postId/languages/:language").delete(auth, controller.removeLanguageFromPost);

// interests
router.route("/:postId/interests").get(auth, controller.getAllInterestedUsersForPost);
router.route("/:postId/interests").post(auth, controller.addLoggedInUsertoInterested);
router.route("/:postId/interests").delete(auth, controller.removeLoggedInUserfromInterested);

// categories

// filter

module.exports = router;