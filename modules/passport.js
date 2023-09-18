const passport = require('passport');
const models = require('../models');
//const { models } = require('mongoose');

var Result = require('../modules/result');
const UserController = require('../controllers/user-controller');

const LocalStrategy = require('passport-local').Strategy; //support local auth(login)

//const bcrypt = require('bcryptjs'); //암호화 도임 


//oauth등 인증 연동을 추가하고자 할때를 대비하여 도입 

//환경 셋업 : 필드, 체크함수 지정 
passport.use('local', new LocalStrategy({
    usernameField: 'email', //declare login.ejb 
    passwordField: 'password', //declare login.ejb 
    passReqToCallback: true
}, function (req, email, password, done) {

    let login_user = {
        email: email,
        password: password
    };

    let result = new Result({
        onOk: function (result) {
            //make session user info
            let model_user = result.resultObj;

            //serialize session info | todo enc
            done(null, {
                id: model_user.id, //enc
                email: model_user.email, //enc
                subscribe: "none", //enc
                userType: model_user.userType, // enc
            })
        },
        onFail: function (result) {
            //login fail
            done(null, false, req.flash('message', `${result.msg}`));
        }
    });

    UserController.localLogin(login_user, result);
}))

//serializeUser란 로그인을 성공한 user의 정보를 session에 저장하는 함수이고, deserializeUser는 페이지에 방문하는 모든 client에 대한 정보를 req.user 변수에 전달해주는 함수이다.
//serializeUser : 로그인에 성공했을 때 유저 정보를 session에 저장하는 기능

//로그인할 때 정보만 들어가는지 체크 
// 세션 정보 : 쓰기 : 암호화 시점 체크
passport.serializeUser(function (user, done) {
    console.log('SAVE SESSION serializeUser()');
    console.log(user);

    done(null, user);
});

//세션 정보 : 읽기 
passport.deserializeUser(function (user, done) {
    console.log('LOAD SESSION deserializeUser()');
    console.log(user);

    //후킹해서 사용할 수 있는 시점 확인 
    done(null, user);
})
module.exports = passport;