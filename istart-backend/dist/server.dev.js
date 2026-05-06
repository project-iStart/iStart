"use strict";

var express = require('express');

var dotenv = require('dotenv');

var cors = require('cors');

var connectDB = require('./config/db');

dotenv.config();
connectDB();
var app = express();
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"]
}));
app.use(express.json()); // Routes

app.use('/api/auth', require('./routes/auth'));
app.use('/api/ideas', require('./routes/ideas'));
app.use('/api/votes', require('./routes/votes'));
app.use('/api/feedback', require('./routes/feedback'));
app.use('/api/join-requests', require('./routes/joinRequests'));
app.use('/api/investment-requests', require('./routes/investmentRequests'));
app.use('/api/discussion', require('./routes/discussion'));
app.use('/api/doc-requests', require('./routes/docRequests'));
app.use('/api/notifications', require('./routes/notifications'));
app.get('/', function (req, res) {
  return res.send('iStart API Running');
});
var PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", function () {
  console.log("Server running on port ".concat(PORT));
});