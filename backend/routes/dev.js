const express = require("express");
const router = express.Router();
const dev = require("../utils/dev");

const controller = require("../controllers/dev");

// userZips
router.route("/userZips").get(dev, controller.getAllAssociationsUserZip);
router.route("/userZips").post(dev, controller.createAssociationUserZip);
router.route("/userZips").delete(dev, controller.deleteAssociationUserZip);

// userLanguages
router.route("/userLanguages").get(dev, controller.getAllAssociationsUserLanguage);
router.route("/userLanguages").post(dev, controller.createAssociationUserLanguage);
router.route("/userLanguages").delete(dev, controller.deleteAssociationUserLanguage);

// postZips
router.route("/postZips").get(dev, controller.getAllAssociationsPostZip);
router.route("/postZips").post(dev, controller.createAssociationPostZip);
router.route("/postZips").delete(dev, controller.deleteAssociationPostZip);

// postLangauges
router.route("/postLanguages").get(dev, controller.getAllAssociationsPostLanguage);
router.route("/postLanguages").post(dev, controller.createAssociationPostLanguage);
router.route("/postLanguages").delete(dev, controller.deleteAssociationPostLanguage);

// postCategories
router.route("/postCategories").get(dev, controller.getAllAssociationsPostCategory);
router.route("/postCategories").post(dev, controller.createAssociationPostCategory);
router.route("/postCategories").delete(dev, controller.deleteAssociationPostCategory);

// postInterests
router.route("/postInterests").get(dev, controller.getAllAssociationsPostInterest);
router.route("/postInterests").post(dev, controller.createAssociationPostInterest);
router.route("/postInterests").delete(dev, controller.deleteAssociationPostInterest);

module.exports = router;