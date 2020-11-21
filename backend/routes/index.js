const express = require("express");
const router = express.Router();

// Subrouters;
const authRouter = require("./auth");
const userRouter = require("./users");
const postsRouter = require("./posts");


const messagesRouter = require("./messages");
const convosRouter = require("./convos");

const postZipsRouter = require("./postZips");
const postInterestsController = require("./postInterests")

// Mount our subrouters to assemble our apiRouter;
router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/posts", postsRouter);


router.use("/messages", messagesRouter);
router.use("/convos", convosRouter);

router.use("/postZips", postZipsRouter);
router.use("/postInterests", postInterestsController)

// Error handling middleware;
router.use((req, res, next) => {
	const error = new Error("Not Found, Please Check URL!");
	error.status = 404;
	next(error);
});

// Export our apiRouter, so that it can be used by our main app in app.js;
module.exports = router;