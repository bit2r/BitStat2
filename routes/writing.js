var express = require('express');
var passport = require('../modules/passport');
var Result = require('../modules/result');
var UserController = require('../controllers/user-controller');
var BoardController = require('../controllers/board-controller');
var WritingController = require('../controllers/writing-controller');
var Util = require('../modules/util');

var router = express.Router();

//---
router.get('/edit/:id', function (req, res, next) {

  let have_permission = false;
  if (UserController.havePermission(req, 0).ok()) {
    have_permission = true;
    console.log(`have_permission|${have_permission}`);
  }
  if (false == have_permission) {
    res.render('login');
    return;
  }

  let result = new Result({
    onOk: function (result) {
      writing_info = JSON.stringify(result.resultObj, null, 2);
      console.log(writing_info);
      res.render('writing-edit', { writing_info: writing_info });
    },
    onFail: function (result) {
      console.log(result.msg);
      res.redirect('back'); //back 
    }
  });

  //check permission 
  let writingId = req.param("id", 0);
  WritingController.writingView({ writingId: writingId }, result);
});

//--- new 
router.get('/write', function (req, res, next) {

  let have_permission = false;
  if (UserController.havePermission(req, 0).ok()) {
    have_permission = true;
    console.log(`have_permission|${have_permission}`);
  }
  if (false == have_permission) {
    res.render('login'); //replace redirect to render
    return;
  }
  let writing_info = JSON.stringify({ id: "", title: "", body: "# title", tag: "", category: "", public: "" }); //default value by joygram 2023/05/22
  res.render('writing-edit', { writing_info: writing_info });
});

router.get('/view/:id', function (req, res, next) {

  let result = new Result({
    onOk: function (result) {
      writing_info = JSON.stringify(result.resultObj, null, 2);
      console.log(writing_info);
      res.render('writing-view', { writing_info: writing_info });
    },
    onFail: function (result) {
      console.log(result.msg);
      res.redirect('/');
    }
  });

  //check permission 
  let writingId = req.param("id", 0);
  WritingController.writingView({ writingId: writingId }, result);
});


router.get('/list/:user_id', function (req, res, next) {
  let result = new Result({
    onOk: function (result) {
      writinglist = JSON.stringify(result.resultObj, null, 2);
      res.render('writing-list', { writinglist: writinglist });
    },
    onFail: function (result) {
      res.redirect('back');
    }
  });

  let have_permission = false;
  if (UserController.havePermission(req, 0).ok()) {
    have_permission = true;
  }
  // 지정안한 경우. 자신의 페이지로   
  let userId = req.param("user_id", 0);
  if (userId == 0 && have_permission) {
    userId = req.user.id;
  }
  console.log(`userId:${userId}`);
  if (userId == 0) {
    req.render('message', { message: `user writings not found` });
    return;
  }

  WritingController.listWriting({ userId: userId }, result);
});

router.post('/save', function (req, res, next) {
  let result = new Result({
    onOk: function (gplat_result) {
      res.redirect('/writing/list');
    },
    onFail: function (gplat_result) {
      res.render('message', {
        message: gplat_result.msg,
      })
    }
  });

  let writing_data = req.body;
  let session_user = req.user;
  writing_data.userId = session_user.id;

  //check permission 
  //login form window 

  WritingController.saveWriting(writing_data, result);
});


//writing/api/save
router.post('/api/save', function (req, res, next) {
  let result = new Result({
    onResult: function (gplat_result) {//common callback
      res.json(gplat_result.data());
    }
  });

  try {
    let writing_data = req.body;
    let session_user = req.user;
    writing_data.userId = session_user.id;
    WritingController.saveWriting(writing_data, result);
  } catch (ex) {
    console.log(ex.message);
    return result.onExceptionOccurred(ex);
  }
});

router.get('/delete/:id', function (req, res, next) {

  //board/:id/writing/list : todo
  let result = new Result({
    onResult: function (gplat_result) {
      res.redirect('/writing/list');
    }
  });

  let writingId = req.param("id", 0);
  WritingController.deleteWriting({ writingId: writingId }, result);
})


module.exports = router;
