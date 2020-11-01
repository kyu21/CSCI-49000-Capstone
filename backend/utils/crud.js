const db = require("../models");

async function getAll(modelName, params, body) {
	try {
		const all = await db[modelName].findAll();
		return all;
	} catch (err) {
		console.log(err);
	}
}

async function getOne(modelName, params, body) {
	try {
		const ele = await db[modelName].findOne({ where: params });
		return ele;
	} catch (err) {
		console.log(err);
	}
}

async function postOne(modelName, params, body) {
	try {
		const newEle = await db[modelName].create(body);
		return newEle;
	} catch (err) {
		console.log(err);
	}
}

async function updateOne(modelName, params, body) {
	try {
		const [numberOfAffectedRows, affectedRows] = await db[modelName].update(
			body,
			{
				where: params,
				returning: true,
				raw: true,
			}
		);
		return affectedRows;
	} catch (err) {
		console.log(err);
	}
}

async function deleteOne(modelName, params, body) {
	try {
		await db[modelName].destroy({ where: params });

		res.status(200).json({
			code: "Success",
		});
	} catch (err) {
		console.log(err);
	}
}

module.exports = {
	getAll: getAll,
	getOne: getOne,
	postOne: postOne,
	updateOne: updateOne,
	deleteOne: deleteOne,
};
