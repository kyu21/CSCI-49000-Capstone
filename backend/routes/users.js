const express = require("express");
const router = express.Router();
const userController = require("../controllers/users");

router.route("/").post(userController.createUser);
router.route("/").get(userController.getAllUsers);
router.route("/:userId").get(userController.getUserById);

module.exports = router;