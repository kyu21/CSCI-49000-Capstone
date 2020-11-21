const express = require("express");
const router = express.Router();

// Subrouters;
const authRouter = require("./auth");
const userRouter = require("./users");


const userLanguagesRouter = require("./userLanguages");
const messagesRouter = require("./messages");
const convosRouter = require("./convos");
const postsRouter = require("./posts");
const languagesRouter = require("./languages");
const zipRouter = require("./zips");
const postZipsRouter = require("./postZips");
const postInterestsController = require("./postInterests")
const keywordsController = require("./keywords");
const postKeywordsController = require("./postKeywords")

// Mount our subrouters to assemble our apiRouter;
router.use("/auth", authRouter);
router.use("/users", userRouter);


router.use("/userLanguages", userLanguagesRouter);
router.use("/messages", messagesRouter);
router.use("/convos", convosRouter);
router.use("/posts", postsRouter);
router.use("/languages", languagesRouter);
router.use("/zips", zipRouter);
router.use("/postZips", postZipsRouter);
router.use("/postInterests", postInterestsController)
router.use("/keywords", keywordsController)
router.use("/postKeywords", postKeywordsController)

// Error handling middleware;
router.use((req, res, next) => {
	const error = new Error("Not Found, Please Check URL!");
	error.status = 404;
	next(error);
});

// Export our apiRouter, so that it can be used by our main app in app.js;
module.exports = router;