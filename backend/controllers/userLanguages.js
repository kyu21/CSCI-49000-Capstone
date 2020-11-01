const db = require("../models");
const modelName = "userLanguages";

const {
	getAll,
	getOne,
	postOne,
	updateOne,
	deleteOne,
} = require("../utils/crud.js");

const userLanguagesController = {
	getAllElements: getAllElements,
	getElement: getElement,
	insertElement: insertElement,
	editElement: editElement,
	deleteElement: deleteElement,
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

async function getAllLanguagesForUser(req, res, next) {
	try {
		const { userId } = req.params;
		const allUserLang = await db.userLanguages.findAll({
			where: {
				userId: userId,
			},
		});

		const allLangInfo = await Promise.all(
			allUserLang.map(
				async (langEle) =>
					await db.languages.findOne({
						where: {
							id: langEle.languageId,
						},
					})
			)
		);

		res.status(200).json(allLangInfo);
	} catch (err) {
		console.log(err);
	}
}

module.exports = userLanguagesController;
