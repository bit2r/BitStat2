var Result = require('../modules/result');
var ResultCode = require('../modules/resultCode');
var models = require('../models');

var UserController = require('../controllers/user-controller');
const { where } = require('sequelize');

module.exports = class WritingController {
    constructor() {
    }

    logInfo() {
    }


    //--------------------------------------
    //글 내용을 가지고 옵니다. 
    static writingView(params, result) {
        models.Users.hasMany(models.Writings, { foreignKey: "userId" })
        models.Writings.belongsTo(models.Users, { foreignKey: 'userId' })


        if (params.writingId == 0) {
            return result.onFail(ResultCode.WRITING_NOT_EXIST, `writingId is empty. cant not show.`);
        }

        let where_cond = {};
        where_cond = { id: params.writingId };
        //page 
        models.Writings.findOne({
            where: where_cond
            //inner join
            , include: [{ // 시퀄라이즈 조인은 기본 inner join
                model: models.Users, // join할 모델
                attributes: ['email'], // select해서 표시할 필드 지정
                required: true
            }]
        })
            .then(function (writing) {

                if (null == writing) {
                    return result.onFail(ResultCode.WRITING_NOT_EXIST, `writing not exist ${params.writingId}`);
                }
                else {
                    console.log('change user email to email');
                    let ret_writing = JSON.parse(JSON.stringify(writing)); //순수 문자열 json으로 변환 
                    console.log(ret_writing);
                    ret_writing.email = ret_writing.User.email; //정보보정
                    return result.onOk(ret_writing, ``);
                }
            }).catch(err => {
                console.error(err);
            });
    }

    static makeUpdateData(writing_view_data) {
        return {
            title: writing_view_data.title,
            body: writing_view_data.body,
            tag: writing_view_data.tag,
            category: writing_view_data.category,
            public: writing_view_data.public,
            userId: writing_view_data.userId
        };
    }

    //create new data  
    static createWriting(writing_view_data, result) {
        console.log("try create writing");

        let update_data = this.makeUpdateData(writing_view_data);

        const user = models.Writings.create(update_data, {
        }).then(function (update_writing) {
            if (null == update_writing) {
                return result.onFail(`create fail|userId:${update_data.userId}|title:${update_data.title}`);
            }
            else {
                console.log(`${update_writing}`);
                //성공이면 onOk
                return result.onOk({}, `create ok:${writing_view_data.title}`);
            }
        }).catch(err => {
            //result.onFail();
            console.error(err);
        });
    }

    static updateWriting(writing_view_data, result) {
        console.log("try update writing");

        //userId는 session에서 override해서 넣어준다. 
        let update_data = this.makeUpdateData(writing_view_data);

        //make 
        //check(select) and insert 
        const user = models.Writings.update(update_data, {
            where: {
                id: writing_view_data.writingId
            }
        }).then(function (update_writing) {

            if (null == update_writing) {
                return result.onFail(null, `update failed|writingId:${update_data.writingId}|userId:${update_data.userId}`);
            }
            console.log(`${update_writing}`);
            //성공이면 onOk
            return result.onOk({}, `update ok`);
        }).catch(err => {
            //result.onFail(``);
            console.error(err);
        });
    }

    //--------------------------------------
    //result객체를 받고 결과세팅 및 처리 상태에 따른 콜백을 호출하는 구조를 가져가도록 한다. by jogyram 2023/05/09
    static saveWriting(writing_view_data, result) {
        // db 처리로 대체 할 수 있음. 
        //id가 없으면 새로 작성 
        //id가 있으면 찾아보고 있으면 갱신 없으면 오류
        console.log(writing_view_data);

        //UserController.havePermission(req, 0);
        //writing_view_data.userId = req.user.id;

        let writingId = parseInt(writing_view_data.writingId);
        console.log(`---- writingId:[${writingId}]`);

        if (isNaN(writingId) || writingId == 0) {
            this.createWriting(writing_view_data, result);
        } else {
            this.updateWriting(writing_view_data, result);
        }

        return new Result().setOk();
    }

    //--------------------------------------
    static listWriting(params, result) {

        models.Users.hasMany(models.Writings, { foreignKey: "userId" })
        models.Writings.belongsTo(models.Users, { foreignKey: 'userId' })
        let where_cond = {};
        if (params.hasOwnProperty("userId")) {
            where_cond = { id: params.userId };
        }
        //page 
        models.Writings.findAll({
            where: where_cond
            //inner join
            , include: [{ // 시퀄라이즈 조인은 기본 inner join
                model: models.Users, // join할 모델
                attributes: ['email'], // select해서 표시할 필드 지정
                required: true
                // where: {
                //     id: params.userId, // on Comment.id = 1
                // },
            }]
        })
            .then(function (writings) {

                if (null == writings) {
                    return result.onFail(ResultCode.WRITING_NOT_EXIST, `user list not exist.`);
                }
                else {
                    console.log('change user email to email');
                    let ret_writing = JSON.parse(JSON.stringify(writings)); //순수 문자열 json으로 변환 
                    console.log(ret_writing);
                    ret_writing.forEach(function (writing) {
                        writing.email = writing.User.email;
                    });
                    return result.onOk(ret_writing, ``);
                }
            }).catch(err => {
                console.error(err);
            });
    }

    //--- 
    static deleteWriting(params, result) {

        const user = models.Writings.destroy({
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