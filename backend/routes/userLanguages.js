const express = require("express");
const router = express.Router();
const userLanguagesController = require("../controllers/userLanguages");

router.route("/:userId").get(userLanguagesController.getAllLanguagesForUser);

module.exports = router;