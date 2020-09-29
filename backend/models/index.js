var fs = require("fs");
var path = require("path");

const dbConfig = require("../config/config.js");

const Sequelize = require("sequelize");
const sequelize = new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: dbConfig.dialect,
    dialectOption: {
        ssl: true,
        native: true,
    },
    define: {
        timestamps: false,
    }
});

const db = {};

// Hack to initialize Sequalize with all models
const basename = path.basename(__filename);
fs.readdirSync(__dirname)
    .filter((file) => {
        return (
            file.indexOf(".") !== 0 && file !== basename && file.slice(-3) === ".js"
        );
    })
    .forEach((file) => {
        var model = require(path.join(__dirname, file))(sequelize, Sequelize.DataTypes);
        db[model.name] = model;
        // console.log(db[model.name]);
    });

Object.keys(db).forEach((modelName) => {
    if (db[modelName].associate) {
        db[modelName].associate(db);
    }
});

db.Sequelize = Sequelize;
db.sequelize = sequelize;
module.exports = db;