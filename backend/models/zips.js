module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"zips",
		{
			id: {
				type: DataTypes.BIGINT,
				allowNull: false,
				primaryKey: true,
				autoIncrement: true,
			},
			zip: {
				type: DataTypes.TEXT,
				allowNull: false,
				unique: true,
			},
			name: {
				type: DataTypes.TEXT,
				allowNull: false,
			},
			createdAt: {
				type: DataTypes.DATE,
				allowNull: false,
			},
			updatedAt: {
				type: DataTypes.DATE,
				allowNull: false,
			},
		},
		{
			tableName: "zips",
		}
	);
};
