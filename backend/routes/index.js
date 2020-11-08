const express = require("express");
const router = express.Router();

// Subrouters;
const userRouter = require("./users");
const userZipsRouter = require("./userZips");
const userLanguagesRouter = require("./userLanguages");
const messagesRouter = require("./messages");
const convosRouter = require("./convos");
const postsRouter = require("./posts");
const languagesRouter = require("./languages");
const zipRouter = require("./zips");
const authRouter = require("./auth");
const postZipsRouter = require("./postZips");

// Mount our subrouters to assemble our apiRouter;
router.use("/users", userRouter);
router.use("/userZips", userZipsRouter);
router.use("/userLanguages", userLanguagesRouter);
router.use("/messages", messagesRouter);
router.use("/convos", convosRouter);
router.use("/posts", postsRouter);
router.use("/languages", languagesRouter);
router.use("/zips", zipRouter);
router.use("/auth", authRouter);
router.use("/postZips", postZipsRouter);

// const cleanup = require("./cleanup")
// router.use("/cleanup", cleanup)

// Error handling middleware;
router.use((req, res, next) => {
	const error = new Error("Not Found, Please Check URL!");
	error.status = 404;
	next(error);
});

// Export our apiRouter, so that it can be used by our main app in app.js;
module.exports = router;
