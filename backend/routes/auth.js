const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth");
const auth = require("../utils/auth");

router.route("/login").post(authController.loginUser);
router.route("/register").post(authController.registerUser);

module.exports = router;