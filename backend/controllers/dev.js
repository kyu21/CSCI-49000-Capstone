const db = require("../models");

const {
    cascadeDeleteConvo,
} = require("../utils/standardize")

// DELETE /dev/convos/:convoId
async function deleteConvo(req, res) {
    try {
        const {
            convoId
        } = req.params;

        let convo = await db.convos.findOne({
            raw: true,
            where: {
                id: convoId
            }
        });
        if (convo !== null) {
            await cascadeDeleteConvo(convoId);

            res.sendStatus(204);
        } else {
            res.status(404).json({
                code: "Error",
                message: `Convo ${convoId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between user and zip, please try again.`,
        });
    }
}

// GET /dev/userZips
async function getAllAssociationsUserZip(req, res) {
    try {
        let allElements = await db.userZips.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between user and zip, please try again.`,
        });
    }
}

// POST /dev/userZips DEV userId, zipId
async function createAssociationUserZip(req, res) {
    try {
        const {
            userId,
            zipId
        } = req.query;

        // check if valid user and valid zip
        let user = await db.users.findOne({
            raw: true,
            where: {
                id: userId
            }
        });
        if (user !== null) {
            let zip = await db.zips.findOne({
                raw: true,
                where: {
                    id: zipId
                }
            });
            if (zip !== null) {
                // check if association exists already
                let userZip = await db.userZips.findOne({
                    raw: true,
                    where: {
                        userId: userId,
                        zipId: zipId
                    }
                });
                if (userZip === null) {
                    userZip = await db.userZips.create({
                        userId: userId,
                        zipId: zipId
                    });
                    userZip = userZip.get({
                        plain: true
                    });

                    res.status(201).json(userZip);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between User ${userId} and Zip ${zipId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `Zip ${zipId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `User ${userId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between user and zip, please try again.`,
        });
    }
}

// DELETE /dev/userZips DEV userId, zipId
async function deleteAssociationUserZip(req, res) {
    try {
        const {
            userId,
            zipId
        } = req.query;

        let userZip = await db.userZips.findOne({
            where: {
                userId: userId,
                zipId: zipId
            }
        })
        if (userZip !== null) {
            await userZip.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between User ${userId} and Zip ${zipId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between user and zip, please try again.`,
        });
    }
}

// GET /dev/userLanguages
async function getAllAssociationsUserLanguage(req, res) {
    try {
        let allElements = await db.userLanguages.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between user and language, please try again.`,
        });
    }
}

// POST /dev/userLanguages DEV userId, languageId
async function createAssociationUserLanguage(req, res) {
    try {
        const {
            userId,
            languageId
        } = req.query;

        // check if valid user and valid language
        let user = await db.users.findOne({
            raw: true,
            where: {
                id: userId
            }
        });
        if (user !== null) {
            let language = await db.languages.findOne({
                raw: true,
                where: {
                    id: languageId
                }
            });
            if (language !== null) {
                // check if association exists already
                let userLanguage = await db.userLanguages.findOne({
                    raw: true,
                    where: {
                        userId: userId,
                        languageId: languageId
                    }
                });
                if (userLanguage === null) {
                    userLanguage = await db.userLanguages.create({
                        userId: userId,
                        languageId: languageId
                    });
                    userLanguage = userLanguage.get({
                        plain: true
                    });

                    res.status(201).json(userLanguage);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between User ${userId} and Language ${languageId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `Language ${languageId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `User ${userId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between user and lanaguage, please try again.`,
        });
    }
}

// DELETE /dev/userLanguages DEV userId, languageId
async function deleteAssociationUserLanguage(req, res) {
    try {
        const {
            userId,
            languageId
        } = req.query;

        let userLanguage = await db.userLanguages.findOne({
            where: {
                userId: userId,
                languageId: languageId
            }
        })
        if (userLanguage !== null) {
            await userLanguage.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between User ${userId} and Language ${languageId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between user and language, please try again.`,
        });
    }
}

// GET /dev/postZips
async function getAllAssociationsPostZip(req, res) {
    try {
        let allElements = await db.postZips.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between post and zip, please try again.`,
        });
    }
}

// POST /dev/postZips DEV postId, zipId
async function createAssociationPostZip(req, res) {
    try {
        const {
            postId,
            zipId
        } = req.query;

        // check if valid post and valid zip
        let post = await db.posts.findOne({
            raw: true,
            where: {
                id: postId
            }
        });
        if (post !== null) {
            let zip = await db.zips.findOne({
                raw: true,
                where: {
                    id: zipId
                }
            });
            if (zip !== null) {
                // check if association exists already
                let postZip = await db.postZips.findOne({
                    raw: true,
                    where: {
                        postId: postId,
                        zipId: zipId
                    }
                });
                if (postZip === null) {
                    postZip = await db.postZips.create({
                        postId: postId,
                        zipId: zipId
                    });
                    postZip = postZip.get({
                        plain: true
                    });

                    res.status(201).json(postZip);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between Post ${postId} and Zip ${zipId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `Zip ${zipId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `Post ${postId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between post and zip, please try again.`,
        });
    }
}

// DELETE /dev/postZips DEV postId, zipId
async function deleteAssociationPostZip(req, res) {
    try {
        const {
            postId,
            zipId
        } = req.query;

        let postZip = await db.postZips.findOne({
            where: {
                postId: postId,
                zipId: zipId
            }
        })
        if (postZip !== null) {
            await postZip.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between Post ${postId} and Zip ${zipId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between post and zip, please try again.`,
        });
    }
}

// GET /dev/postLanguages
async function getAllAssociationsPostLanguage(req, res) {
    try {
        let allElements = await db.postLanguages.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between post and language, please try again.`,
        });
    }
}

// POST /dev/postLanguages DEV postId, languageId
async function createAssociationPostLanguage(req, res) {
    try {
        const {
            postId,
            languageId
        } = req.query;

        // check if valid post and valid language
        let post = await db.posts.findOne({
            raw: true,
            where: {
                id: postId
            }
        });
        if (post !== null) {
            let language = await db.languages.findOne({
                raw: true,
                where: {
                    id: languageId
                }
            });
            if (language !== null) {
                // check if association exists already
                let postLanguage = await db.postLanguages.findOne({
                    raw: true,
                    where: {
                        postId: postId,
                        languageId: languageId
                    }
                });
                if (postLanguage === null) {
                    postLanguage = await db.postLanguages.create({
                        postId: postId,
                        languageId: languageId
                    });
                    postLanguage = postLanguage.get({
                        plain: true
                    });

                    res.status(201).json(postLanguage);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between Post ${postId} and Language ${languageId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `Language ${languageId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `Post ${postId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between post and lanaguage, please try again.`,
        });
    }
}

// DELETE /dev/postLanguages DEV postId, languageId
async function deleteAssociationPostLanguage(req, res) {
    try {
        const {
            postId,
            languageId
        } = req.query;

        let postLanguage = await db.postLanguages.findOne({
            where: {
                postId: postId,
                languageId: languageId
            }
        })
        if (postLanguage !== null) {
            await postLanguage.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between Post ${postId} and Language ${languageId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between post and language, please try again.`,
        });
    }
}

// GET /dev/postCategories
async function getAllAssociationsPostCategory(req, res) {
    try {
        let allElements = await db.postCategories.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between post and category, please try again.`,
        });
    }
}

// POST /dev/postCategories DEV postId, categoryId
async function createAssociationPostCategory(req, res) {
    try {
        const {
            postId,
            categoryId
        } = req.query;

        // check if valid post and valid category
        let post = await db.posts.findOne({
            raw: true,
            where: {
                id: postId
            }
        });
        if (post !== null) {
            let category = await db.categories.findOne({
                raw: true,
                where: {
                    id: categoryId
                }
            });
            if (category !== null) {
                // check if association exists already
                let postCategory = await db.postCategories.findOne({
                    raw: true,
                    where: {
                        postId: postId,
                        categoryId: categoryId
                    }
                });
                if (postCategory === null) {
                    postCategory = await db.postCategories.create({
                        postId: postId,
                        categoryId: categoryId
                    });
                    postCategory = postCategory.get({
                        plain: true
                    });

                    res.status(201).json(postCategory);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between Post ${postId} and Category ${categoryId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `Category ${categoryId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `Post ${postId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between post and category, please try again.`,
        });
    }
}

// DELETE /dev/postCategories DEV postId, categoryId
async function deleteAssociationPostCategory(req, res) {
    try {
        const {
            postId,
            categoryId
        } = req.query;

        let postCategory = await db.postCategories.findOne({
            where: {
                postId: postId,
                categoryId: categoryId
            }
        })
        if (postCategory !== null) {
            await postCategory.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between Post ${postId} and Category ${categoryId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between post and category, please try again.`,
        });
    }
}

// GET /dev/postInterests
async function getAllAssociationsPostInterest(req, res) {
    try {
        let allElements = await db.postInterests.findAll({
            raw: true
        });

        res.status(200).json(allElements);
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error getting all associations between post and users interested, please try again.`,
        });
    }
}

// POST /dev/postInterests DEV postId, userId
async function createAssociationPostInterest(req, res) {
    try {
        const {
            postId,
            userId
        } = req.query;

        // check if valid post and valid user
        let post = await db.posts.findOne({
            raw: true,
            where: {
                id: postId
            }
        });
        if (post !== null) {
            let user = await db.users.findOne({
                raw: true,
                where: {
                    id: userId
                }
            });
            if (user !== null) {
                // check if association exists already
                let postInterest = await db.postInterests.findOne({
                    raw: true,
                    where: {
                        postId: postId,
                        userId: userId
                    }
                });
                if (postInterest === null) {
                    postInterest = await db.postInterests.create({
                        postId: postId,
                        userId: userId
                    });
                    postInterest = postInterest.get({
                        plain: true
                    });

                    res.status(201).json(postInterest);
                } else {
                    res.status(400).json({
                        code: "Error",
                        message: `Assocation between Post ${postId} and User ${userId} already exists, please try again.`,
                    });
                }
            } else {
                res.status(404).json({
                    code: "Error",
                    message: `User ${userId} not found, please try again.`,
                });
            }
        } else {
            res.status(404).json({
                code: "Error",
                message: `Post ${postId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error creating association between post and users interested, please try again.`,
        });
    }
}

// DELETE /dev/postInterests DEV postId, userId
async function deleteAssociationPostInterest(req, res) {
    try {
        const {
            postId,
            userId
        } = req.query;

        let postInterest = await db.postInterests.findOne({
            where: {
                postId: postId,
                userId: userId
            }
        })
        if (postInterest !== null) {
            await postInterest.destroy();

            res.sendStatus(204);
        } else {
            res.status(400).json({
                code: "Error",
                message: `Assocation between Post ${postId} and User ${userId} not found, please try again.`,
            });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            code: "Error",
            message: `Error deleting association between post and users interested, please try again.`,
        });
    }
}

module.exports = {
    deleteConvo,
    getAllAssociationsUserZip,
    createAssociationUserZip,
    deleteAssociationUserZip,
    getAllAssociationsUserLanguage,
    createAssociationUserLanguage,
    deleteAssociationUserLanguage,
    getAllAssociationsPostZip,
    createAssociationPostZip,
    deleteAssociationPostZip,
    getAllAssociationsPostLanguage,
    createAssociationPostLanguage,
    deleteAssociationPostLanguage,
    getAllAssociationsPostCategory,
    createAssociationPostCategory,
    deleteAssociationPostCategory,
    getAllAssociationsPostInterest,
    createAssociationPostInterest,
    deleteAssociationPostInterest
};