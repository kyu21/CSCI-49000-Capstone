module.exports = function (sequelize, DataTypes) {
    return sequelize.define('languages', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        name: {
            type: DataTypes.TEXT,
            allowNull: false
        }
    }, {
        tableName: 'languages'
    });
};