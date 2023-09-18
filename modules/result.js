//GplatResult : 결과 코드, 메시지, 콜백, 결과 객체, 리다이렉터 등을 지정하여 결과 흐름, 리턴 없이 흐름제어가 가능하도록 구성한다. by joygram 2023/05/09
module.exports = class Result {
    static type_e = {
        _NONE: 0,
        Fail: 1,
        Ok: 2,
        Warn: 3,
        Notcomplete: 4,
        NotHandled: 5,
        ExceptionOccurred: 6,
        Ignore: 7,
        Fatal: 8,
        AlreadyProcessed: 9,
        OkWithExtraProcess: 10,
        _END: 11,
    };

    constructor(params = null) {
        this.type = 0;
        this.code = 0;
        this.msg = "";
        this.resultObj = {}; //리턴 결과 객체 
        this.okCallback = null;
        this.failCallback = null;
        this.exceptionCallback = null;
        this.resultCallback = null;

        if (null != params) {
            if (params.hasOwnProperty('onOk')) {
                this.okCallback = params.onOk; //성공시 콜백 
            }
            if (params.hasOwnProperty('onFail')) {
                this.failCallback = params.onFail; //실패시 콜백         
            }
            if (params.hasOwnProperty('onException')) {
                this.exceptionCallback = params.onException; //exception콜백         
            }

            if (params.hasOwnProperty('onResult')) {
                this.resultCallback = params.onResult; //공통 콜백:오류관계없이 결과객체를 넘겨줄 때 사용 
            }
        }
    }

    //resultObj를 result_data로 변경하여 전송 
    data() {
        return {
            type: this.type,
            code: this.code,
            msg: this.msg,
            result_data: JSON.stringify(this.resultObj)
        }
    }

    ok() {
        return (this.type == Result.type_e.Ok);
    }
    fail() {
        return (this.type == Result.type_e.Fail);
    }

    //결과값을 저장하고 콜백을 실행한다. 
    onOk(resultObj, msg) {
        this.setOk(resultObj, msg);
        if (null != this.okCallback) {
            this.okCallback(this);
        } else if (null != this.resultCallback) {
            this.resultCallback(this);
        }
    }
    //실패시 결과값을 저장하고 콜백을 실행한다.
    onFail(code, msg) {
        this.setFail(code, msg);
        if (null != this.failCallback) {
            this.failCallback(this);
        } else if (null != this.resultCallback) {
            this.resultCallback(this);
        }
    }

    onExceptionOccurred(ex) {
        console.log(ex);
        this.setExceptionOccurred(ex.message);
        if (null != this.exceptionCallback) {
            this.exceptionCallback(this);
        } else if (null != this.failCallback) {
            this.failCallback(this);
        } else if (null != this.resultCallback) {
            this.resultCallback(this);
        }
    }

    onResult(resultObj, msg) {
        if (null != this.resultCallback) {
            this.resultCallback(this);
        } else {
            console.log(`[ERROR]no result callback !!!`);
        }
    }

    setOk(resultObj, msg = '') {
        this.type = Result.type_e.Ok;
        this.msg = msg;
        this.resultObj = resultObj;
        this.log();
        return this;
    }
    setFail(code, msg) {
        this.type = Result.type_e.Fail;
        this.code = code;
        this.msg = msg;
        this.log();
        return this;
    }

    setExceptionOccurred(msg) {
        this.type = Result.type_e.ExceptionOccurred;
        this.code = 0;
        this.msg = msg;
        this.log();
        return this;
    }

    logInfo() {
        return `type:${this.type}|code:${this.code}|msg:${this.msg}|resultObj:${JSON.stringify(this.resultObj)}`;
    }

    log() {
        console.log(this.logInfo());
    }
}