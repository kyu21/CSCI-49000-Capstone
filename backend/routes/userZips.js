const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const userZipsController = require("../controllers/userZips");

router.route("/").get(auth, userZipsController.getAllElements);
router.route("/:id").get(auth, userZipsController.getElement);
router.route("/").post(auth, userZipsController.insertElement);
router.route("/:id").put(auth, userZipsController.editElement);
router.route("/:id").delete(auth, userZipsController.deleteElement);
router.route("/user/:userId").get(auth, userZipsController.getAllZipsforUser);
router.route("/zip/:zipId").get(auth, userZipsController.getAllUsersforZip);

module.exports = router;
