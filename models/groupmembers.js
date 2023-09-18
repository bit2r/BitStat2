'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class GroupMembers extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  GroupMembers.init({
    groupId: DataTypes.BIGINT,
    userId: DataTypes.BIGINT,
    memberType: DataTypes.INTEGER,
    level: DataTypes.INTEGER,
    nick: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'GroupMembers',
  });
  return GroupMembers;
};