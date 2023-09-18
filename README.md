# BitStat2
BitStat2

## Setup 

### `.env`

add your `OPEN_API_KEY`

```
OPENAI_API_KEY=
```



### ChatGPT role 

`config/config.json`

```
{
  "development": {
    "username": "",
    "password": "",
    "host": "",
    "database": "db_dev",
    "dialect": "sqlite",
    "storage": "./dev.db",
    "dialectOptions": {}
  },
  "gpt_role": {
    "role": "system",
    "content": "너는 광명 시청 보좌관이다.\n너의 이름은 광명이 이다.\n"
  }
}
```



## How to Run 

```
npm install 
npm run start
```



