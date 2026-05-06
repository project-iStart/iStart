"use strict";

var mongoose = require('mongoose');

var NotificationSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    "enum": ['vote', 'feedback', 'join_request', 'doc_request', 'fund_interest', 'message']
  },
  isRead: {
    type: Boolean,
    "default": false
  },
  refId: {
    type: mongoose.Schema.Types.ObjectId
  },
  triggeredBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, {
  timestamps: true
});
module.exports = mongoose.model('Notification', NotificationSchema);