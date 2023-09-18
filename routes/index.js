var express = require('express');
var passport = require('../modules/passport');
var Result = require('../modules/result');
var UserController = require('../controllers/user-controller');

var router = express.Router();
/* GET home page. */
router.get('/', function (req, res, next) {

  let have_permission = false;
  if (UserController.havePermission(req, 0).ok()) {
    have_permission = true;
    console.log(`have_permission|${have_permission}`);
  }

  res.render('index', { title: 'ChatGPT', havePermission: have_permission });
});

//list
router.get('/my_writing', function (req, res, next) {

  let have_permission = false;
  if (UserController.havePermission(req, 0).ok()) {
    have_permission = true;
    console.log(`have_permission|${have_permission}`);
  }
  if (false == have_permission) {
    res.render('login'); //replace redirect to render
    return;
  }

  let url = `/writing/list/${req.user.id}`;
  res.redirect(url);
});



//view:login 
router.get('/login', function (req, res, next) {
  res.render('login', {
    label_id: 'email',
    label_pw: 'password'
  });
}
);

router.get('/login/success', function (req, res, next) {
  let result = new Result();
  result.setOk(Result.type_e.Ok, 1, "success");
  result.log();

  res.render('login-success');
});

router.get('/login/fail', function (req, res, next) {
  res.render('login-fail');
});

//logout처리 by joygram 2023/05/11
router.get('/logout', function (req, res, next) {

  req.logout(function (err) {

    if (err) {
      return next(err);
    }
    // redirect after session save 
    req.session.save(function () {
      res.redirect('/');
    });
  });
});


//passport자체처리 수행 : api like action 
router.post('/login/auth',
  passport.authenticate('local', {
    successRedirect: 'back', //로그인 요청한 페이지로 이동 
    failureRedirect: '/login/fail',
    failureFlash: true
  })
);

module.exports = router;
