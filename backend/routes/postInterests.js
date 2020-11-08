const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const postInterestsController = require("../controllers/postInterests");

router.route("/:postId").get(auth, postInterestsController.getPostInterestByPostId);
router.route("/:postId").post(auth, postInterestsController.addLoggedInUsertoInterested);
router.route("/:postId").delete(auth, postInterestsController.removeLoggedInUsertoInterested);
router.route("/:postId/user/:userId").post(auth, postInterestsController.backdoor);

module.exports = router;