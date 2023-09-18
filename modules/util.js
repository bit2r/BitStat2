var Result = require('../modules/result');

var Util = {};

//exception guard
Util.safeExec = function (f, result) {
    try {
        return f();
    } catch (e) {
        result.onExceptionOccurred(e);
    }
}

module.exports = Util;