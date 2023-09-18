var express = require('express');
var models = require('../models');
var router = express.Router();
var userController = require('../controllers/user-controller');
const Result = require('../modules/result');

router.post('/signup', function (req, res, next) {
  console.log(`req email:${req.body.email}|password:${req.body.password}`);
  //to controller 
  let view_data = req.body;

  //함수를 직접 지정 
  let result = new Result({
    onOk: function (gplat_result) { res.redirect('back'); },
    onFail: function (gplat_result) {
      console.log(gplat_result.msg);
      res.render('message', {
        message: gplat_result.msg,
      })
    }
  });

  userController.create(view_data, result);
});

module.exports = router;
