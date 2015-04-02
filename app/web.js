// This spins up a simple Express server
// to serve our static site

var gzippo = require('gzippo');
var express = require('express');

if(process.env.NODETIME_ACCOUNT_KEY) {
  require('nodetime').profile({
    accountKey: process.env.NODETIME_ACCOUNT_KEY,
    appName: '' // optional
  });
}

var app = express();

//app.use(express.logger('dev'));
app.use(gzippo.staticGzip("" + __dirname + ""));
app.listen(process.env.PORT || 5000);