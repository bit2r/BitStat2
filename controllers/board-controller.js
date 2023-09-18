var Result = require('../modules/result');
var ResultCode = require('../modules/resultCode');
var models = require('../models');

var UserController = require('./user-controller');
var WritingController = require('./writing-controller');

const { where } = require('sequelize');

module.exports = class BoardController {
    constructor() {
    }

    logInfo() {
    }


    static makeUpdateData(board_view_data) {
        return {
            title: board_view_data.name,
            desc: board_view_data.desc,
            boardType: board_view_data.boardType,
            accessType: board_view_data.accessType,
            //생성시
            userId: board_view_data.userId,
            groupId: board_view_data.groupId
        };
    }

    //create new data  
    static create(view_data, result) {
        console.log("try create board");

        let update_data = this.makeUpdateData(view_data);

        const user = models.Boards.create(update_data, {
        }).then(function (update_board) {
            if (null == update_board) {
                return result.onFail(`create fail|userId:${update_data.userId}|title:${update_data.title}`);
            }
            else {
                return result.onOk({}, `create ok:${view_data.title}`);
            }
        }).catch(err => {
            //result.onFail();
            console.error(err);
        });
    }

    static update(board_view_data, result) {
        console.log("try update board");

        //userId는 session에서 override해서 넣어준다. 
        let update_data = this.makeUpdateData(board_view_data);

        //make 
        //check(select) and insert 
        const user = models.Boards.update(update_data, {
            where: {
                id: board_view_data.writingId
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
    static save(board_view_data, result) {
        // db 처리로 대체 할 수 있음. 
        //id가 없으면 새로 작성 
        //id가 있으면 찾아보고 있으면 갱신 없으면 오류
        console.log(board_view_data);

        //owner여부확인 
        //UserController.havePermission(req, 0);
        //board_view_data.userId = req.user.id;

        let writingId = parseInt(board_view_data.writingId);
        console.log(`---- writingId:[${writingId}]`);

        if (isNaN(writingId) || writingId == 0) {
            this.create(board_view_data, result);
        } else {
            this.update(board_view_data, result);
        }
    }

    //--------------------------------------
    static list(params, result) {

        models.Users.hasMany(models.Boards, { foreignKey: "userId" })
        models.Boards.belongsTo(models.Users, { foreignKey: 'userId' })
        let where_cond = {};
        if (params.hasOwnProperty("userId")) {
            where_cond = { id: params.userId };
        }
        //page 
        models.Boards.findAll({
            where: where_cond
            //inner join
            , include: [{ // 시퀄라이즈 조인은 기본 inner join
                model: models.Users, // join할 모델
                attributes: ['email'], // select해서 표시할 필드 지정
                // where: {
                //     id: params.userId, // on Comment.id = 1
                // },
            }]
        })
            .then(function (Boards) {

                if (null == Boards) {
                    return result.onFail(ResultCode.WRITING_NOT_EXIST, `user list not exist.`);
                }
                else {
                    console.log('change user email to email');
                    //1줄짜리 사용자 정보 보정이 필요 ... 어떻게?
                    let ret_writing = JSON.parse(JSON.stringify(Boards)); //순수 문자열 json으로 변환 
                    ret_writing.forEach(function (writing) {
                        writing.email = writing.user.email;
                    });
                    return result.onOk(ret_writing, ``);
                }
            }).catch(err => {
                console.error(err);
            });
    }

    //--- 
    static delete(params, result) {

        const user = models.Boards.destroy({
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