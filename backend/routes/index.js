const express = require("express");
const router = express.Router();

router.get("/", (req, res, next) => res.send("LocalHelper Backend API"));

// Subrouters;
const authRouter = require("./auth");
const userRouter = require("./users");
const postsRouter = require("./posts");
const miscRouter = require("./misc");
const devRouter = require("./dev")

// Mount our subrouters to assemble our apiRouter;
router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/posts", postsRouter);
router.use("/misc", miscRouter);
router.use("/dev", devRouter);

// Error handling middleware;
router.use((req, res, next) => {
	const error = new Error("Not Found, Please Check URL!");
	error.status = 404;
	next(error);
});

// Export our apiRouter, so that it can be used by our main app in app.js;
module.exports = router;