const Sequelize = require("sequelize");

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('messages', {
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
        convoId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'convos',
                key: 'id'
            }
        },
        body: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        // created_at: {
        //     type: 'TIMESTAMP',
        //     defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        //     allowNull: false
        // },
        // updated_at: {
        //     type: 'TIMESTAMP',
        //     defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        //     allowNull: false
        // },
    }, {
        tableName: 'messages'
    });
};