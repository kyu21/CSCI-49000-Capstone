const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const postInterestsController = require("../controllers/postInterests");

router.route("/:postId").get(auth, postInterestsController.getPostInterestByPostId);
router.route("/:postId").post(auth, postInterestsController.addLoggedInUsertoInterested);
router.route("/:postId").delete(auth, postInterestsController.removeLoggedInUsertoInterested);

module.exports = router;