module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"userZips",
		{
			id: {
				type: DataTypes.BIGINT,
				allowNull: false,
				primaryKey: true,
				autoIncrement: true,
			},
			userId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "users",
					key: "id",
				},
			},
			zipId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "zips",
					key: "id",
				},
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
			tableName: "userZips",
		}
	);
};
