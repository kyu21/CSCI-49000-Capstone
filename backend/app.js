if (process.env.NODE_ENV !== "production") {
    require("dotenv").config();
}

var logger = require('morgan');
var express = require('express');
var cookieParser = require('cookie-parser');

var apiRouter = require('./routes/index');
var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({
    extended: false
}));
app.use(cookieParser());

app.get("/", (req, res, next) => res.send("LocalHelper Backend"));
app.use('/api', apiRouter);

module.exports = app;