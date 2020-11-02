var jwtDecode = require("jwt-decode");

const decodeJwt = async (reqHeaders) => {
	const authHeader = reqHeaders.authorization;
	var decoded = jwtDecode(authHeader);
	return decoded;
};
module.exports = decodeJwt;
