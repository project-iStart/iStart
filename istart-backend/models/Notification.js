const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  user:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  message: { type: String, required: true },
  type:    { type: String, enum: ['vote', 'feedback', 'joinRequest', 'funding', 'docRequest'] },
  read:    { type: Boolean, default: false },
  refId:   { type: mongoose.Schema.Types.ObjectId }, // reference to the related document
}, { timestamps: true });

module.exports = mongoose.model('Notification', NotificationSchema);