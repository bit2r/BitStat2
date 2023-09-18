'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Boards', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.BIGINT
      },
      title: {
        type: Sequelize.STRING
      },
      desc: {
        type: Sequelize.STRING
      },
      category: {
        type: Sequelize.INTEGER
      },
      accessLevel: {
        type: Sequelize.INTEGER
      },
      userId: {
        type: Sequelize.BIGINT,
        references: { model: 'Users', key: 'id' }
      },
      groupId: {
        type: Sequelize.BIGINT,
        references: { model: 'Groups', key: 'id' }
      },
      boardType: {
        type: Sequelize.INTEGER
      },
      showType: {
        type: Sequelize.INTEGER
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Boards');
  }
};