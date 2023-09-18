class WebSpeech {


    static onComplete = function (web_speech) { console.log("empty onComplete"); }
    static mic_img = '/images/mic.gif';

    constructor(params = null) {
        this.create_email = false;
        this.final_transcript = '';
        this.recognizing = false;
        this.ignore_onend;
        this.start_timestamp;
        this.recognition = {};

        if (null != params) {
            if (params.hasOwnProperty('onComplete')) {
                WebSpeech.onComplete = params.onComplete; //성공시 콜백 
                console.log("set onComplete callback");
            }
        }
        else {
            WebSpeech.onComplete = null;
        }
    }

    upgrade() {

    }

    static showInfo(str) {
        console.log(str);
        //webix.message({ text: str });
    }


    prepare() {
        if (!('webkitSpeechRecognition' in window)) {
            this.upgrade();
            return false;
        } else {
            //start_button.style.display = 'inline-block';
            this.recognition = new webkitSpeechRecognition();
            //this.recognition.continuous = true;
            //this.recognition.interimResults = true;
            this.final_transcript = '';

            this.recognition.onstart = function () {
                this.recognizing = true;
                WebSpeech.showInfo('info_speak_now');
                web_speech_img.src = '/images/mic-animate.gif';
            };

            this.recognition.onerror = function (event) {
                if (event.error == 'no-speech') {
                    web_speech_img.src = WebSpeech.mic_img;
                    WebSpeech.showInfo('info_no_speech');
                    this.ignore_onend = true;
                }
                if (event.error == 'audio-capture') {
                    web_speech_img.src = WebSpeech.mic_img;
                    WebSpeech.showInfo('info_no_microphone');
                    this.ignore_onend = true;
                }
                if (event.error == 'not-allowed') {
                    if (event.timeStamp - this.start_timestamp < 100) {
                        WebSpeech.showInfo('info_blocked');
                    } else {
                        WebSpeech.showInfo('info_denied');
                    }
                    this.ignore_onend = true;
                }
            };

            this.recognition.onend = function () {
                this.recognizing = false;
                if (this.ignore_onend) {
                    return;
                }
                web_speech_img.src = WebSpeech.mic_img;


                if (!this.final_transcript) {
                    WebSpeech.showInfo('info_start');
                    return;
                }
                // if (window.getSelection) {
                //     window.getSelection().removeAllRanges();
                //     var range = document.createRange();
                //     range.selectNode(document.getElementById('final_span'));
                //     window.getSelection().addRange(range);
                // }
            };

            //이쪽 원본비교. 
            this.recognition.onresult = function (event) {
                var interim_transcript = '';
                for (var i = event.resultIndex; i < event.results.length; ++i) {
                    if (event.results[i].isFinal) {
                        this.final_transcript = event.results[i][0].transcript;
                        console.log(`transcript:${this.final_transcript}`);
                    } else {
                        interim_transcript += event.results[i][0].transcript;
                    }
                }
                console.log("before callback");

                if (WebSpeech.onComplete != null) {
                    WebSpeech.onComplete(this);
                }


                //인식한 텍스트 반영 
                // final_span.innerHTML = this.final_transcript;
                // interim_span.innerHTML = linebreak(interim_transcript);
                // if (this.final_transcript || interim_transcript) {
                //     showButtons('inline-block');
                // }

            };
        }
        return true;
    }

    start() {
        if (false == this.prepare()) {
            console.log("음성인식 준비 실패");
            return;
        }

        if (!('webkitSpeechRecognition' in window)) {
            this.upgrade();
            return;
        }

        if (this.recognizing) {
            console.log("음성인식을 종료합니다.");
            //this.recognition.stop();
            return;
        }
        this.final_transcript = '';
        this.recognition.lang = 'ko-KR';
        this.recognition.start();
        console.log("recognition started");

        this.ignore_onend = false;

        //final_span.innerHTML = '';
        //interim_span.innerHTML = '';

        web_speech_img.src = '/images/mic-slash.gif';
        WebSpeech.showInfo('info_allow');
        this.start_timestamp = Date.now();
    }

    stop() {
        web_speech_img.src = '/images/mic.gif';
        this.recognition.stop();
    }
}