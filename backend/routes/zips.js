const express = require("express");
const router = express.Router();
const zipsController = require("../controllers/zips");

router.route("/").get(zipsController.getAllElements);
router.route("/:id").get(zipsController.getElement);
router.route("/").post(zipsController.insertElement);
router.route("/:id").put(zipsController.editElement);
router.route("/:id").delete(zipsController.deleteElement);

module.exports = router;
