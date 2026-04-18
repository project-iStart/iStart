const mongoose = require('mongoose');

const DocRequestSchema = new mongoose.Schema({
  investor:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startupIdea: { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  requestMessage: { type: String },
  responseMessage: { type: String },
  fileUrl:     { type: String },
  status:      { type: String, enum: ['pending', 'responded'], default: 'pending' },
}, { timestamps: true });

module.exports = mongoose.model('DocRequest', DocRequestSchema);