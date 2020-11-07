const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const postZipsController = require("../controllers/postZips");

router.route("/").get(auth, postZipsController.getAllElements);
router.route("/:id").get(auth, postZipsController.getElement);
router.route("/").post(auth, postZipsController.insertElement);
router.route("/:id").put(auth, postZipsController.editElement);
router.route("/:id").delete(auth, postZipsController.deleteElement);
router.route("/zip/:zipId").get(auth, postZipsController.getAllPostsforZip);

module.exports = router;
