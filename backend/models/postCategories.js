module.exports = function (sequelize, DataTypes) {
    return sequelize.define(
        "postCategories", {
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
            categoryId: {
                type: DataTypes.INTEGER,
                allowNull: false,
                references: {
                    model: "categories",
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
        }, {
            tableName: "postCategories",
        }
    );
};