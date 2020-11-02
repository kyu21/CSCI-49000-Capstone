module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"userConvos",
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
			convoId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "convos",
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
			tableName: "userConvos",
		}
	);
};
