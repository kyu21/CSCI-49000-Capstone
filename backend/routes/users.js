const express = require("express");
const router = express.Router();
const userController = require("../controllers/users");

router.route("/").get(userController.getAllUsers);

module.exports = router;