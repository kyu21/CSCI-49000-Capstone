const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const userController = require("../controllers/users");

router.route("/").get(userController.getAllUsers);
router.route("/me").get(auth, userController.getLoggedInUser);
router.route("/:userId").get(userController.getUserById);

module.exports = router;
