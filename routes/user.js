var express = require('express');
var router = express.Router();

router.get('/signup', function (req, res, next) {
  res.render('user-signup');
});

//
router.get('/logout', function (req, res) {
  req.logout();
  req.session.save((err) => {
    //res.redirect('/');
    res.redirect('back'); //redirect to back
  });
});
//req.logout()을 하면 req.user 없어짐
//현재의 세션상태를 session에 저장하고 리다이렉트 한다.
//req.session.destroy()를 하면 session정보를 지울 수 있다.

module.exports = router;
