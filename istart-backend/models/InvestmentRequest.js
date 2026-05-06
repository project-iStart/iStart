const mongoose = require('mongoose');

const InvestmentRequestSchema = new mongoose.Schema({
  investor:     { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startupIdea:  { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  fundingAmount: { type: Number }, // Optional: desired investment amount
  message:      { type: String },
  status:       { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
}, { timestamps: true });

module.exports = mongoose.model('InvestmentRequest', InvestmentRequestSchema);
