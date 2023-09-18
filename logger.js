const winston = require('winston');

const consoleTransport = new winston.transports.Console();

winston.add(consoleTransport);

winston.info('Getting started with Winston');
module.exports = winston;
