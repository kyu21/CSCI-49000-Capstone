const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const userController = require("../controllers/users");

router.route("/").get(auth, userController.getAllUsers);
router.route("/me").get(auth, userController.getLoggedInUser);
router.route("/:userId").get(auth, userController.getUserById);
router.route("/").put(auth, userController.editLoggedInUser);
router.route("/").delete(auth, userController.deleteLoggedInUser);

module.exports = router;