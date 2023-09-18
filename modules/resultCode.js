
var ResultCode = {
    NONE: 0,
    USER_EXIST: 1,
    USER_NOT_EXIST: 2,
    USER_CREATE_FAIL: 3,
    USER_NO_PERMISSION: 4,
    USER_NO_SESSION: 5,
    USER_PASSWORD_ERROR: 6,

    WRITING_NOT_EXIST: 11,
    WRITING_CREATE_FAIL: 12,
    WRITING_UPDATE_FAIL: 13,
    WRITING_DELETE_FAIL: 14,

    SCRIPT_ERROR: 400,
    SERVER_ERROR: 500,
}

module.exports = ResultCode;