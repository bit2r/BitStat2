const { Configuration, OpenAIApi } = require("openai");
var Result = require('../modules/result');
var Config = require('../config/config.json');

//openai api chatbot
module.exports = class ChatGpt {
    static type_e = {
        _NONE: 0,
        _END: 11,
    };



    static query(gpt_prompt, result) {
        //history가 필요한 경우 별도 지정처리를 하거나 스트림 방식의 구현으로 대체 by joygram 2023/08/12 
        let gpt_messages = [
            Config.gpt_role,
            {
                "role": "user",
                "content": gpt_prompt
            }
        ];

        const configuration = new Configuration({
            apiKey: process.env.OPENAI_API_KEY,
        });
        const openai = new OpenAIApi(configuration);

        console.log(`api_key:${process.env.OPENAI_API_KEY}`);
        const chatCompletion = openai.createChatCompletion({
            model: 'gpt-3.5-turbo',
            messages: gpt_messages,
            temperature: 0.9,
            max_tokens: 2048,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0.6,
            stop: [" Human:", " AI:"],
        }).then((response) => {
            // json 데이터만 전송 
            let ret_data = { answer: '' };
            response.data.choices.forEach((choice) => {
                ret_data.answer += `${ret_data.answer}${choice.message.content}`;
            });

            let length = ret_data.answer.length;
            result.onOk(ret_data, `answer length:${length}`);

            //console.log(response.data.choices);
        }).catch(err => {
            //openai api detail error by joygram 2023/08/11
            let detail = '';
            if (err.response?.data?.error != null) {
                let gpt_err = err.response.data.error;
                detail = `${gpt_err.type}|${gpt_err.message}`;
            }

            result.onFail(`${err} ${detail}`);
        });
    }

    //res 제거
    static query4(gpt_prompt, result) {

        let gpt_messages = [
            {
                "role": "user",
                "content": gpt_prompt
            }
        ];

        const openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY
        })


        const response = openai.chat.completions.create({
            model: 'gpt-3.5-turbo',
            messages: gpt_messages,
            temperature: 0.9,
            max_tokens: 150,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0.6,
            stop: [" Human:", " AI:"],
        }).then((response) => {
            // sending the response data back to the client 
            //데이터만 전송 
            res.json(response.data.choices);
        });
    }

}