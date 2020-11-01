module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"userPosts",
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
			postId: {
				type: DataTypes.INTEGER,
				allowNull: false,
				references: {
					model: "posts",
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
			tableName: "userPosts",
		}
	);
};
