const mongoose = require('mongoose');

const VoteSchema = new mongoose.Schema({
  user:        { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startupIdea: { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  type:        { type: String, enum: ['upvote', 'downvote'], required: true },
}, { timestamps: true });

// One vote per user per idea
VoteSchema.index({ user: 1, startupIdea: 1 }, { unique: true });

module.exports = mongoose.model('Vote', VoteSchema);