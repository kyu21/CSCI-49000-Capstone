const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const zipsController = require("../controllers/zips");

router.route("/").get(auth, zipsController.getAllElements);
router.route("/:id").get(auth, zipsController.getElement);
router.route("/").post(auth, zipsController.insertElement);
router.route("/:id").put(auth, zipsController.editElement);
router.route("/:id").delete(auth, zipsController.deleteElement);

module.exports = router;
