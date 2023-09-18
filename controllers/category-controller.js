var Result = require('../modules/result');
var ResultCode = require('../modules/resultCode');
var models = require('../models');

var UserController = require('./user-controller');
var WritingController = require('./writing-controller');

const { where } = require('sequelize');

module.exports = class CategoryController {
    constructor() {
    }

    logInfo() {
    }

    static makeUpdateData(view_data) {
        return {
            data: view_data.data,
            //생성시
            userId: view_data.userId,
            groupId: view_data.groupId
        };
    }

    static create(view_data, result) {
        console.log("try create category");

        let update_data = this.makeUpdateData(view_data);

        const user = models.Categories.create(update_data, {
        }).then(function (model_data) {
            if (null == model_data) {
                return result.onFail(`create fail|userId:${update_data.userId}|title:${update_data.title}`);
            }
            else {
                console.log(`${model_data}`);
                return result.onOk({}, `create ok:${view_data.data}`);
            }
        }).catch(err => {
            result.onExceptionOccurred(err);
        });
    }

    static update(view_data, result) {
        let update_data = this.makeUpdateData(view_data);

        const user = models.Categories.update(update_data, {
            where: {
                id: view_data.userId
            }
        }).then(function (update_writing) {
            if (null == update_writing) {
                return result.onFail(null, `update failed|userId:${update_data.userId}`);
            }
            console.log(`${update_writing}`);
            return result.onOk({}, `update ok`);
        }).catch(err => {
            //result.onFail(``);
            console.error(err);
        });
    }

    //--------------------------------------
    static select(params, result) {

        models.Users.hasMany(models.Categories, { foreignKey: "userId" })
        models.Categories.belongsTo(models.Users, { foreignKey: 'userId' })
        let where_cond = {};
        if (params.hasOwnProperty("userId")) {
            where_cond = { id: params.userId };
        }

        let init_data = {
            body: {},
            groupId: 0,
            userId: params.userId
        };

        models.Categories.findOne({
            where: where_cond
        })
            .then(function (model_data) {
                if (null == model_data) {
                    //생성 
                    return result.onFail(ResultCode.WRITING_NOT_EXIST, `no category`);
                }
                else {
                    let ret_data = JSON.parse(JSON.stringify(model_data)); //순수 문자열 json으로 변환 
                    return result.onOk(ret_data, ``);
                }
            }).catch(err => {
                console.error(err);
            });
    }

    //--- 
    static delete(params, result) {

        const user = models.Categories.destroy({
            where: {
                id: params.writingId
            }
        }).then(function () {
            return result.onOk({}, `deleted [${params.writingId}]`);
        }).catch(err => {
            result.onFail(resultCode.WRITING_DELETE_FAIL, `delete fail [${params.writingId}]`);
            console.error(err);
        });
    }
}