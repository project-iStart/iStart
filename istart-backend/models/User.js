const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name:     { type: String, required: true },
  email:    { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['founder', 'collaborator', 'investor'], required: true },
  bio:      { type: String, default: '' },
  // Founder-specific
  companyName: { type: String, default: '' },
  startupStage: { type: String, default: '' },

  // Collaborator-specific
  skills: { type: [String], default: [] },
  availability: { type: String, default: '' },

  // Investor-specific
  investmentFocus: { type: String, default: '' },
  portfolioLink: { type: String, default: '' },
  profileImage: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);