module.exports = function (sequelize, DataTypes) {
    return sequelize.define(
        "postKeywords", {
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
            keywordId: {
                type: DataTypes.INTEGER,
                allowNull: false,
                references: {
                    model: "keywords",
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
            tableName: "postKeywords",
        }
    );
};