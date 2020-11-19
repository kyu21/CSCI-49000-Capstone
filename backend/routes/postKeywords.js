const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const postKeywordsController = require("../controllers/postKeywords");

router.route("/").get(auth, postKeywordsController.getAllElements);
router.route("/:id").get(auth, postKeywordsController.getElement);
router.route("/").post(auth, postKeywordsController.insertElement);
router.route("/:id").put(auth, postKeywordsController.editElement);
router.route("/:id").delete(auth, postKeywordsController.deleteElement);

module.exports = router;