var express = require('express');
var router = express.Router();
var userController = require('../controllers/user-controller');

var Result = require('../modules/result');
var ResultCode = require('../modules/resultCode');

router.get('/userlist', function (req, res, next) {

  let userlist = {}

  let result = new Result({
    onOk: function (result) {
      userlist = JSON.stringify(result.resultObj, null, 2);
      console.log(userlist);
      res.render('admin-userlist', { userlist: userlist });
    },
    onFail: function (result) {
      console.log(result.msg);
      res.redirect('/');
    }
  });

  // api/userlist : json string : result,  
  //params page limit filter
  userController.userList({}, result);

});

module.exports = router;
