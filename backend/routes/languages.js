const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const languagesController = require("../controllers/languages");

router.route("/").get(auth, languagesController.getAllElements);
router.route("/:id").get(auth, languagesController.getElement);
router.route("/").post(auth, languagesController.insertElement);
router.route("/:id").put(auth, languagesController.editElement);
router.route("/:id").delete(auth, languagesController.deleteElement);

module.exports = router;
