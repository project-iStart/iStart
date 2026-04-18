const mongoose = require('mongoose');

const DiscussionThreadSchema = new mongoose.Schema({
  startupIdea: { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  title:       { type: String },
}, { timestamps: true });

module.exports = mongoose.model('DiscussionThread', DiscussionThreadSchema);