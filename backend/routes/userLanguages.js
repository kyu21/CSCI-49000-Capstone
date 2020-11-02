const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");
const userLanguagesController = require("../controllers/userLanguages");

router.route("/").get(auth, userLanguagesController.getAllElements);
router.route("/:id").get(auth, userLanguagesController.getElement);
router.route("/").post(auth, userLanguagesController.insertElement);
router.route("/:id").put(auth, userLanguagesController.editElement);
router.route("/:id").delete(auth, userLanguagesController.deleteElement);

module.exports = router;
