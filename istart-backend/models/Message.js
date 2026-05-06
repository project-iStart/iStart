const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  thread:  { type: mongoose.Schema.Types.ObjectId, ref: 'DiscussionThread', required: true },
  sender:  { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  // content may be empty if attachments are provided
  content: { type: String },
  // optional attachments (documents, images) for the message
  attachments: [
    {
      url: { type: String, required: true },
      filename: { type: String },
      mimeType: { type: String },
    }
  ],
}, { timestamps: true });

module.exports = mongoose.model('Message', MessageSchema);