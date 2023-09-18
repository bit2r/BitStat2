var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var log = require('./logger');

const expressSession = require('express-session');
const passport = require('./modules/passport');
const flash = require('connect-flash'); // what is this ?

var indexRouter = require('./routes/index');
var userRouter = require('./routes/user');
var apiUserRouter = require('./routes/api-user');
var adminRouter = require('./routes/admin');
var writingRouter = require('./routes/writing');
var chatgptRouter = require('./routes/chatgpt');

//.env 활성화 by joygram 2023/08/11
require('dotenv').config();

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));

app.use(express.json()) // for parsing application/json
app.use(express.urlencoded({ extended: true })) // for parsing application/x-www-form-urlencoded
//app.use(express.urlencoded({ extended: false })); //for post method 

app.use(cookieParser());

app.use(express.static(path.join(__dirname, 'public')));

//add to use passport by joygram 
app.use(flash()); // what is this ?
//todo : session store 
app.use(expressSession({
  secret: 'secret key',
  resave: true,
  saveUninitialized: true,
  cookie: {
    // Session expires after 1 min of inactivity.  1min = 60000 by joygram 2023/05/03
    expires: 60000 * 20
  }
}));
app.use(passport.initialize());
app.use(passport.session());

app.use('/', indexRouter);
app.use('/user', userRouter);
app.use('/api/user', apiUserRouter); // add user api by joygram 2023/04/25
app.use('/admin', adminRouter); // add admin by joygram 2023/05/09
app.use('/writing', writingRouter); // writing by joygram 2023/05/25
app.use('/chatgpt', chatgptRouter); // ai by joygram 2023/08/08

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  log.info(`${req.query}`);
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
