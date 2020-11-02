const db = require("../models");
const modelName = "userZips";

const {
	getAll,
	getOne,
	postOne,
	updateOne,
	deleteOne,
} = require("../utils/crud.js");

const userZipsController = {
	getAllElements: getAllElements,
	getElement: getElement,
	insertElement: insertElement,
	editElement: editElement,
	deleteElement: deleteElement,
	getAllZipsforUser: getAllZipsforUser,
};

async function getAllElements(req, res) {
	try {
		const elements = await getAll(modelName, req.params, req.body);

		res.status(200).json(elements);
	} catch (err) {
		console.log(err);
	}
}

async function getElement(req, res) {
	try {
		const { id } = req.params;
		const element = await getOne(modelName, { id: id }, req.body);

		res.status(200).json(element);
	} catch (err) {
		console.log(err);
	}
}

async function insertElement(req, res) {
	try {
		const element = await postOne(modelName, req.params, req.body);

		res.status(201).json(element);
	} catch (err) {
		console.log(err);
	}
}

async function editElement(req, res) {
	try {
		const { id } = req.params;
		const element = await updateOne(modelName, { id: id }, req.body);

		res.status(200).json(element);
	} catch (err) {
		console.log(err);
	}
}

async function deleteElement(req, res) {
	try {
		const { id } = req.params;
		await deleteOne(modelName, { id: id }, req.body);

		res.status(204);
	} catch (err) {
		console.log(err);
	}
}

async function getAllZipsforUser(req, res) {
	try {
		const { userId } = req.params;

		let zips = await db.userZips.findAll({
			raw: true,
			where: { userId: userId },
		});
		let zipIds = zips.map((z) => z.zipId);
		zips = await db.zips.findAll({ raw: true, where: zipIds });

		res.status(200).json(zips);
	} catch (err) {
		console.log(err);
	}
}
// /user
// /zip
// mass add
// mass edit

module.exports = userZipsController;
