const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const controller = require("../controllers/misc");

// zips
router.route("/zips").get(auth, controller.getAllZips);
router.route("/zips/:zipId").get(auth, controller.getZipById);
router.route("/zips").post(auth, controller.createZip);
router.route("/zips/:zipId").delete(auth, controller.deleteZip);

// languages
router.route("/languages").get(auth, controller.getAllLanguages);
router.route("/languages/:languageId").get(auth, controller.getLanguageById);
router.route("/languages").post(auth, controller.createLanguage);
router.route("/languages/:languageId").delete(auth, controller.deleteLanguage);

// categories
router.route("/categories").get(auth, controller.getAllCategories);
router.route("/categories/:categoryId").get(auth, controller.getCategoryById);
router.route("/categories").post(auth, controller.createCategory);
router.route("/categories/:categoryId").delete(auth, controller.deleteCategory);

module.exports = router;