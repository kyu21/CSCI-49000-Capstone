const express = require("express");
const router = express.Router();
const userZipsController = require("../controllers/userZips");

router.route("/:userId").get(userZipsController.getAllZipsForUser);

module.exports = router;