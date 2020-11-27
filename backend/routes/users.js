const express = require("express");
const router = express.Router();
const auth = require("../utils/auth");

const controller = require("../controllers/users");

// basic routes
router.route("/").get(auth, controller.getAllUsers);
router.route("/me").get(auth, controller.getLoggedInUser);
router.route("/").put(auth, controller.editLoggedInUser);
router.route("/").delete(auth, controller.deleteLoggedInUser);

// convos
router.route("/convos").get(auth, controller.getUserConvos);
router.route("/convos/:convoId").get(auth, controller.getConvoByConvoId);
router.route("/convos/:userId").post(auth, controller.createConvoWithUser);

// messages
router.route("/convos/:convoId/messages").get(auth, controller.getAllMessagesOfConvo);
router.route("/convos/:convoId/messages").post(auth, controller.sendMessage);

// needs to be here because of route precedence
router.route("/:userId").get(auth, controller.getUserById);

// zips
router.route("/:userId/zips").get(auth, controller.getUserZips);
router.route("/:userId/zips").post(auth, controller.addUserZips);
router.route("/:userId/zips").delete(auth, controller.removeZipsFromUser);

// languages
router.route("/:userId/languages").get(auth, controller.getUserLanguages);
router.route("/:userId/languages").post(auth, controller.addUserLanguages);
router.route("/:userId/languages").delete(auth, controller.removeLanguagesFromUser);



module.exports = router;