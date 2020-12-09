var fs = require("fs");
var path = require("path");

const Sequelize = require("sequelize");
const sequelize = new Sequelize(process.env.DATABASE_URL, {
	dialect: "postgres",
	dialectOptions: {
		ssl: {
			require: true,
			rejectUnauthorized: false
		}
	},
	define: {
		timestamps: true,
	},
	timestamp: "America/New_York",
});

const db = {};

// Hack to initialize Sequalize with all models
const basename = path.basename(__filename);
fs.readdirSync(__dirname)
	.filter((file) => {
		return (
			file.indexOf(".") !== 0 &&
			file !== basename &&
			file.slice(-3) === ".js"
		);
	})
	.forEach((file) => {
		var model = require(path.join(__dirname, file))(
			sequelize,
			Sequelize.DataTypes
		);
		db[model.name] = model;
		console.log(db[model.name]);
	});

sequelize.sync();
db.Sequelize = Sequelize;
db.sequelize = sequelize;
module.exports = db;