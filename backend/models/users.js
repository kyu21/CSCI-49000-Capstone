module.exports = function (sequelize, DataTypes) {
    return sequelize.define('users', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        first: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        last: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        gender: {
            type: DataTypes.CHAR,
            allowNull: false
        },
        phone: {
            type: DataTypes.TEXT,
            allowNull: false,
            unique: true
        },
        email: {
            type: DataTypes.TEXT,
            allowNull: false,
            unique: true
        },
        password: {
            type: DataTypes.TEXT,
            allowNull: false
        },
    }, {
        tableName: 'users'
    });
};