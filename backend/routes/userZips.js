const express = require("express");
const router = express.Router();
const userZipsController = require("../controllers/userZips");

router.route("/").get(userZipsController.getAllElements);
router.route("/:id").get(userZipsController.getElement);
router.route("/").post(userZipsController.insertElement);
router.route("/:id").put(userZipsController.editElement);
router.route("/:id").delete(userZipsController.deleteElement);

module.exports = router;
