module.exports = function (sequelize, DataTypes) {
	return sequelize.define(
		"postZips",
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
			tableName: "postZips",
		}
	);
};
