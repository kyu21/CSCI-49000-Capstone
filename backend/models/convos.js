module.exports = function (sequelize, DataTypes) {
    return sequelize.define('convos', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'users',
                key: 'id'
            }
        },
    }, {
        tableName: 'convos'
    });
};