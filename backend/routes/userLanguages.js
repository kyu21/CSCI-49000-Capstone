const express = require("express");
const router = express.Router();
const userLanguagesController = require("../controllers/userLanguages");

router.route("/").get(userLanguagesController.getAllElements);
router.route("/:id").get(userLanguagesController.getElement);
router.route("/").post(userLanguagesController.insertElement);
router.route("/:id").put(userLanguagesController.editElement);
router.route("/:id").delete(userLanguagesController.deleteElement);

module.exports = router;
