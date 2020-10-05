module.exports = function (sequelize, DataTypes) {
    return sequelize.define('zips', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        zip: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        name: {
            type: DataTypes.TEXT,
            allowNull: false
        }
    }, {
        tableName: 'zips'
    });
};