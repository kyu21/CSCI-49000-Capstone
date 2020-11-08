module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"postInterests",
		{
			id: {
				type: DataTypes.BIGINT,
				allowNull: false,
				primaryKey: true,
				autoIncrement: true,
			},
			postId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "posts",
					key: "id",
				},
			},
			userId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "users",
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
			tableName: "postInterests",
		}
	);
};
