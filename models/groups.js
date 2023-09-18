'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Groups extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Groups.init({
    groupType: DataTypes.INTEGER,
    name: DataTypes.STRING,
    userId: DataTypes.BIGINT
  }, {
    sequelize,
    modelName: 'Groups',
  });
  return Groups;
};