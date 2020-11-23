module.exports = function (sequelize, DataTypes) {
    return sequelize.define(
        "postLanguages", {
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
            languageId: {
                type: DataTypes.INTEGER,
                allowNull: false,
                references: {
                    model: "languages",
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
            tableName: "postLanguages",
        }
    );
};