//for web browser
// Request and Result : 결과 코드, 메시지, 콜백, 결과 객체, 리다이렉터 등을 지정하여 결과 흐름, 리턴 없이 흐름제어가 가능하도록 구성한다. by joygram 2023/05/09
//WebReq추가 
class Requester {
    static result_e = {
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
        this.result_data = ''; //외부로 부터 지정한 결과 문자열 by joygram 2023/08/11

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

    data() {
        return {
            type: this.type,
            code: this.code,
            msg: this.msg,
            result_data: this.result_data
        }
    }

    ok() {
        return (this.type == Requester.result_e.Ok);
    }
    fail() {
        return (this.type == Requester.result_e.Fail);
    }

    //set from json 
    set(in_json) {
        this.type = in_json.type;
        this.code = in_json.code;
        this.msg = in_json.msg;
        this.result_data = in_json.result_data; //결과 데이터 받아내기
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
        this.setExceptionOccurred(ex.message);
        if (null != this.exceptionCallback) {
            this.exceptionCallback(this);
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
        this.type = Requester.result_e.Ok;
        this.msg = msg;
        this.resultObj = resultObj;
        this.log();
        return this;
    }
    setFail(code, msg) {
        this.type = Requester.result_e.Fail;
        this.code = code;
        this.msg = msg;
        this.log();
        return this;
    }

    setExceptionOccurred(msg) {
        this.type = Requester.result_e.ExceptionOccurred;
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

    //client post
    post(in_url, in_post_data) {
        var this_result = this;
        webix.ajax()
            .post(in_url, in_post_data)
            .then(function (res) {
                let result_json = res.json();
                this_result.set(result_json);
                if (this_result.ok()) {
                    this_result.onOk();
                } else {
                    webix.alert(`ERRROR:${this_result.msg}`);
                }
                //redirect
            })
            .catch(function (err) {
                console.log(err);
            });
    }
}

