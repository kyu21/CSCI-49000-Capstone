module.exports = function (sequelize, DataTypes) {
    return sequelize.define('userLanguages', {
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
        languageId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'languages',
                key: 'id'
            }
        }
    }, {
        tableName: 'userLanguages'
    });
};