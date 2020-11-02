const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const userZipsController = require("../controllers/userZips");

router.route("/").get(auth, userZipsController.getAllElements);
router.route("/:id").get(auth, userZipsController.getElement);
router.route("/").post(auth, userZipsController.insertElement);
router.route("/:id").put(auth, userZipsController.editElement);
router.route("/:id").delete(auth, userZipsController.deleteElement);

module.exports = router;
