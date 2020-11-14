const express = require("express");
const router = express.Router();
const convoController = require("../controllers/convos");

router.route("/:userId").post(convoController.createConvo);
router.route("/cofu/:userId").get(convoController.getAllConvosForUser);
router.route("/uofc/:convoId").get(convoController.getAllUsersinConvo);
router.route("/add/:userId/:convoId").put(convoController.addUser);
router.route("/leave/:userId/:convoId").put(convoController.leaveConvo);
router.route("/:convoId").delete(convoController.deleteConvo);

module.exports = router;