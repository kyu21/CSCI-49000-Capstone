const dev = async (req, res, next) => {
	console.log(req.headers);
	const devSecret = req.headers.secret;
	if (devSecret) {
		if (devSecret === process.env.DEV_SECRET) {
			next();
		} else {
			return res.sendStatus(403);
		}
	} else {
		res.sendStatus(401);
	}
};

module.exports = dev;