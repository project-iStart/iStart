const mongoose = require('mongoose');

const DiscussionThreadSchema = new mongoose.Schema({
  startupIdea: { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  title:       { type: String },
  // participants explicitly list users in this thread (founder, collaborators, investors, etc.)
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
}, { timestamps: true });

module.exports = mongoose.model('DiscussionThread', DiscussionThreadSchema);