const db = require("../models");

const languageController = {
    getAllLanguages: getAllLanguages,
    createLanguage: createLanguage,
    getLanguageById: getLanguageById,
};

async function getAllLanguages(req, res) {
    try {
        const allLanguages = await db.languages.findAll();

        res.status(200).json(allLanguages);
    } catch (err) {
        console.log(err);
    }
}

async function createLanguage(req, res) {
    try {
        const {
            name
        } = req.body;

        let newLanguage = await db.languages.create({
            name,
        });

        res.status(201).json(newLanguage);
    } catch (err) {
        console.log(err);
    }
}

async function getLanguageById(req, res) {
    try {
        const {
            languageId
        } = req.params;

        let language = await db.languages.findOne({
            raw: true,
            where: {
                id: languageId,
            },
        });

        res.status(200).json(language);
    } catch (err) {
        console.log(err);
    }
}

module.exports = languageController;