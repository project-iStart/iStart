const mongoose = require('mongoose');

const JoinRequestSchema = new mongoose.Schema({
  collaborator: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startupIdea:  { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  message:      { type: String },
  status:       { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
}, { timestamps: true });

module.exports = mongoose.model('JoinRequest', JoinRequestSchema);