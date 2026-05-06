const mongoose = require('mongoose');

const StartupIdeaSchema = new mongoose.Schema({
  founder:          { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title:            { type: String, required: true },
  description:      { type: String, required: true },
  problemStatement: { type: String },
  category:         { type: String },
  stage:            { type: String, enum: ['Idea', 'MVP', 'Growth', 'Scaling'] },
  pitchDeckUrl:     { type: String },
  bookmarkedBy:     [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  communityScore:   { type: Number, default: 0 },
  fundingInterest:  { type: Boolean, default: false },
  teamMembers:      [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  approvedInvestors: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  fundingInterests: [
    {
      investor:    { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      expressedAt: { type: Date, default: Date.now },
    },
  ],
}, { timestamps: true });

module.exports = mongoose.model('StartupIdea', StartupIdeaSchema);