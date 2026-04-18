const mongoose = require('mongoose');

const FeedbackSchema = new mongoose.Schema({
  user:        { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startupIdea: { type: mongoose.Schema.Types.ObjectId, ref: 'StartupIdea', required: true },
  category:    { type: String, enum: ['Market', 'Team', 'Product', 'Finance', 'General'] },
  rating:      { type: Number, min: 1, max: 5, required: true },
  comment:     { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Feedback', FeedbackSchema);