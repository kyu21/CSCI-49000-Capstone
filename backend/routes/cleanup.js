const express = require("express");
const router = express.Router();
const controller = require("../controllers/cleanup");

router.route("/").get(controller.cleanup);

module.exports = router;
