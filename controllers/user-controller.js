var Result = require('../modules/result');
var ResultCode = require('../modules/resultCode');
var models = require('../models');
var CategoryController = require('./category-controller');
const BoardController = require('./board-controller');


module.exports = class UserController {
    constructor() {
    }

    logInfo() {
    }

    //-----------------------------------------
    //로그인 & 페이지 권한 보유여부 체크, permission level
    static havePermission(req, need_user_type) {
        //passport session을 사용하는 경우 `user`가 존재한다.
        //권한 레벨을 체크한다.  
        if (req.user) {
            if (req.user.userType < need_user_type) {
                return new Result().setFail(ResultCode.USER_NO_PERMISSION, "user permission not have");
            }
            return new Result().setOk();

        } else {
            return new Result().setFail(ResultCode.USER_NO_SESSION, "user session not exist.");
        }
    }

    //--------------------------------------
    //result객체를 받고 결과세팅 및 처리 상태에 따른 콜백을 호출하는 구조를 가져가도록 한다. by jogyram 2023/05/09
    static create(view_data, result) {
        const user = models.Users.findOne({ //select
            where: {
                email: view_data.email
            }
        }).then(function (select_model_data) {
            if (null == select_model_data) {

                const new_user = models.Users.create({ //insert
                    email: view_data.email,
                    password: view_data.password

                }).then(function (model_data) {
                    if (null == model_data) {
                        return result.onFail(ResultCode.USER_CREATE_FAIL, `[ERROR] can not create user|${view_data.email}`);

                    }
                    //폭포수 디자인으로 맨 마지막에 호출: createion order : category, board 
                    let category_result = new Result({
                        onOk: function () {
                            let board_result = new Result({
                                onOk: function () { return result.onOk(model_data, `${view_data.email} registered.`); },
                                onFail: function () { return result.onFail(ResultCode.USER_CREATE_FAIL, `[ERROR] can not create initial user board|email:${view_data.email}`); }
                            });
                            let init_board = { userId: model_data.id, title: "board" };
                            BoardController.create(init_board, board_result);
                        },
                        onFail: function () { return result.onFail(ResultCode.USER_CREATE_FAIL, `[ERROR] can not create initial user category|email ${view_data.email}`); }
                    });
                    let init_category = { userId: model_data.id }; // category 0: 글로벌 
                    CategoryController.create(init_category, category_result);

                }).catch(err => {
                    result.onExceptionOccurred(err);
                });
            }
            else {
                return result.onFail(ResultCode.USER_EXIST, `already exist user ${select_model_data.email}`);
            }
        }).catch(err => {
            return result.onExceptionOccurred(err);
        });
    }

    //--------------------------------------
    //admin: 사용자 목록을 가지고 옵니다. pw는 제외 
    static select(params, result) {
        //params: page / limit / filter etc
        //attributes: { exclude: ['password'] } //해당 컬럼만 제외 
        models.Users.findAll({ attributes: ['id', 'email', 'loginAt', 'updatedAt', 'createdAt'] })
            .then(function (users) {

                if (null == users) {
                    return result.onFail(ResultCode.USER_NOT_EXIST, `user list not exist.`);
                }
                else {
                    return result.onOk(users, ``);
                }

            }).catch(err => {
                result.onExceptionOccurred(err);
            });
    }

    //--------------------------------------
    //auth: locallogin
    static localLogin(login_user, result) {
        models.Users.findOne({ //select
            where: {
                email: login_user.email
            }
        }).then(function (model_user) {

            if (null != model_user) {
                //enc password and compare 
                if (login_user.password != model_user.password) {
                    return result.onFail(ResultCode.USER_PASSWORD_ERROR, `invalid password or user not exist`)
                }
                console.log(`${model_user.email} login success`);
                return result.onOk(model_user, ``);
            }
            else {
                return result.onFail(ResultCode.USER_NOT_EXIST, `${login_user.email} no exist`);
            }

        }).catch(err => {
            console.error(err);
        });
    }
}