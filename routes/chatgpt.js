var express = require('express');
const { OPEN_READWRITE } = require('sqlite3');
var router = express.Router();

var Result = require('../modules/result');
var ChatGpt = require('../modules/chatgpt');


router.get('/chatgpt', function (req, res, next) {
  res.render('chatgpt');
});

// api/chat open ai에 요청보내기 
router.post('/ask', function (req, res, next) {
  const gpt_prompt = req.body.prompt;
  if (gpt_prompt == null) {
    console.log("no gpt prompt");
  }

  console.log(`gpt_prompt:${gpt_prompt}`);

  let result = new Result({
    //common callback
    onResult: function (gplat_result) {
      console.log(gplat_result.data());
      res.json(gplat_result.data());
    }
  });
  ChatGpt.query(gpt_prompt, result);

});

module.exports = router;
