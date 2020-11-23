const db = require("../models");

const {
    cascadeDeleteZip,
    cascadeDeleteLanguage,
    cascadeDeleteCategory
} = require("../utils/standardize")

require('@gouch/to-title-case');


// GET /zips AUTH
async function getAllZips(req, res) {
    try {
        let zips = await db.zips.findAll({
            raw: true
        });

        res.status(200).json(zips);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all zips, please try again.`,
        });
    }
}

// GET /zips/:zipId AUTH
async function getZipById(req, res) {
    try {
        const {
            zipId
        } = req.params;

        let dbZip = await db.zips.findOne({
            raw: true,
            where: {
                id: zipId
            }
        });

        if (dbZip !== null) {
            res.status(200).json(dbZip);
        } else {
            res.status(404).json({})
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting zip, please try again.`,
        });
    }
}

// POST /zips AUTH
async function createZip(req, res) {
    try {
        const {
            zip
        } = req.body;

        // validate input
        if (typeof zip === "string" && zip.length !== 0) {
            // check if zip already exists
            let dbZip = await db.zips.findOne({
                raw: true,
                where: {
                    zip: zip
                }
            });
            if (dbZip === null) {
                let newZip = await db.zips.create({
                    zip: zip
                });
                newZip = newZip.get({
                    plain: true
                });

                res.status(201).json(newZip);
            } else {
                res.status(400).json({
                    code: "Error",
                    message: `Zip already exists, please try again.`,
                });
            }
        } else {
            res.status(400).json({
                code: "Error",
                message: `Zip field must consist of non-empty string, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating zip, please try again.`,
        });
    }
}

// DELETE /zips/:zipId AUTH
async function deleteZip(req, res) {
    try {
        const {
            zipId
        } = req.params;

        let dbZip = await db.zips.findOne({
            where: {
                id: zipId
            }
        });
        if (dbZip !== null) {
            await dbZip.destroy();
            cascadeDeleteZip(zipId);

            res.sendStatus(204);
        } else {
            res.status(404).json({
                code: "Error",
                message: `Zip ${zipId} does not exist, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting zip, please try again.`,
        });
    }
}

// GET /languages AUTH
async function getAllLanguages(req, res) {
    try {
        let languages = await db.languages.findAll({
            raw: true
        });

        res.status(200).json(languages);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all languages, please try again.`,
        });
    }
}

// GET /languages/:languageId AUTH
async function getLanguageById(req, res) {
    try {
        const {
            languageId
        } = req.params;

        let dbLang = await db.languages.findOne({
            raw: true,
            where: {
                id: languageId
            }
        });

        if (dbLang !== null) {
            res.status(200).json(dbLang);
        } else {
            res.status(404).json({})
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting language, please try again.`,
        });
    }
}

// POST /languages AUTH
async function createLanguage(req, res) {
    try {
        const {
            language
        } = req.body;

        // validate input
        if (typeof language === "string" && language.length !== 0) {
            let lang = language.toTitleCase();

            // check if language already exists
            let dbLang = await db.languages.findOne({
                raw: true,
                where: {
                    name: lang
                }
            });
            if (dbLang === null) {
                let newLang = await db.languages.create({
                    name: lang
                });
                newLang = newLang.get({
                    plain: true
                });

                res.status(201).json(newLang);
            } else {
                res.status(400).json({
                    code: "Error",
                    message: `Language already exists, please try again.`,
                });
            }
        } else {
            res.status(400).json({
                code: "Error",
                message: `Language field must consist of non-empty string, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating language, please try again.`,
        });
    }
}

// DELETE /languages/:languageId AUTH
async function deleteLanguage(req, res) {
    try {
        const {
            languageId
        } = req.params;

        let dbLang = await db.languages.findOne({
            where: {
                id: languageId
            }
        });
        if (dbLang !== null) {
            await dbLang.destroy();
            cascadeDeleteLanguage(dbLang.id);

            res.sendStatus(204);
        } else {
            res.status(404).json({
                code: "Error",
                message: `Language ${languageId} does not exist, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting language, please try again.`,
        });
    }
}

// GET /categories AUTH
async function getAllCategories(req, res) {
    try {
        let categories = await db.categories.findAll({
            raw: true
        });

        res.status(200).json(categories);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all categories, please try again.`,
        });
    }
}

// GET /categories/:categoryId AUTH
async function getCategoryById(req, res) {
    try {
        const {
            categoryId
        } = req.params;

        let dbCategory = await db.categories.findOne({
            raw: true,
            where: {
                id: categoryId
            }
        });

        if (dbCategory !== null) {
            res.status(200).json(dbCategory);
        } else {
            res.status(404).json({})
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting category, please try again.`,
        });
    }
}

// POST /categories AUTH
async function createCategory(req, res) {
    try {
        const {
            category
        } = req.body;

        // validate input
        if (typeof category === "string" && category.length !== 0) {
            let newCategory = category.toTitleCase();

            // check if zip already exists
            let dbCategory = await db.categories.findOne({
                raw: true,
                where: {
                    name: newCategory
                }
            });
            if (dbCategory === null) {
                let newCategoryDB = await db.categories.create({
                    name: newCategory
                });
                newCategoryDB = newCategoryDB.get({
                    plain: true
                });

                res.status(201).json(newCategoryDB);
            } else {
                res.status(400).json({
                    code: "Error",
                    message: `Category already exists, please try again.`,
                });
            }
        } else {
            res.status(400).json({
                code: "Error",
                message: `Category field must consist of non-empty string, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating category, please try again.`,
        });
    }
}

// DELETE /categories/:categoryId AUTH
async function deleteCategory(req, res) {
    try {
        const {
            categoryId
        } = req.params;

        let dbCategory = await db.categories.findOne({
            where: {
                id: categoryId
            }
        });
        if (dbCategory !== null) {
            await dbCategory.destroy();
            cascadeDeleteCategory(categoryId);

            res.sendStatus(204);
        } else {
            res.status(404).json({
                code: "Error",
                message: `Category ${categoryId} does not exist, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting category, please try again.`,
        });
    }
}

module.exports = {
    getAllZips: getAllZips,
    getZipById: getZipById,
    createZip: createZip,
    deleteZip: deleteZip,
    getAllLanguages: getAllLanguages,
    getLanguageById: getLanguageById,
    createLanguage: createLanguage,
    deleteLanguage: deleteLanguage,
    getAllCategories: getAllCategories,
    getCategoryById: getCategoryById,
    createCategory: createCategory,
    deleteCategory: deleteCategory
};