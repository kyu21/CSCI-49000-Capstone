const express = require("express");
const router = express.Router();
const languageController = require("../controllers/languages");

router.route("/").get(languageController.getAllLanguages);
router.route("/").post(languageController.createLanguage);
router.route("/:languageId").get(languageController.getLanguageById);

module.exports = router;