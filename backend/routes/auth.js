const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth");
const auth = require("../utils/auth");

router.route("/login").post(authController.loginUser);
router.route("/register").post(authController.registerUser);
router.route("/test/:zip").get(authController.test)

module.exports = router;