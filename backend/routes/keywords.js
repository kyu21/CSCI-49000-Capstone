const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const keywordsController = require("../controllers/keywords");

router.route("/").get(auth, keywordsController.getAllElements);
router.route("/:id").get(auth, keywordsController.getElement);
router.route("/").post(auth, keywordsController.insertElement);
router.route("/:id").put(auth, keywordsController.editElement);
router.route("/:id").delete(auth, keywordsController.deleteElement);

module.exports = router;