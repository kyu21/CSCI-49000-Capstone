module.exports = function (sequelize, DataTypes) {
    return sequelize.define('posts', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        title: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        dateCreated: {
            type: DataTypes.DATE,
            allowNull: false
        }
    }, {
        tableName: 'posts'
    });
};