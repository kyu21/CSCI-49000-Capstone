const express = require("express");
const router = express.Router();

// Subrouters;
const userRouter = require("./users");
const userZipsRouter = require("./userZips");
const userLanguagesRouter = require("./userLanguages");
const postsRouter = require("./posts");
const languageRouter = require("./languages");
const zipRouter = require("./zips");
const authRouter = require("./auth");

// Mount our subrouters to assemble our apiRouter;
router.use("/users", userRouter);
router.use("/userZips", userZipsRouter);
router.use("/userLanguages", userLanguagesRouter);
router.use("/posts", postsRouter);
router.use("/languages", languageRouter);
router.use("/zips", zipRouter);
router.use("/auth", authRouter);

// Error handling middleware;
router.use((req, res, next) => {
	const error = new Error("Not Found, Please Check URL!");
	error.status = 404;
	next(error);
});

// Export our apiRouter, so that it can be used by our main app in app.js;
module.exports = router;
