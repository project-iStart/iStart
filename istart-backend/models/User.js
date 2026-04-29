const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name:     { type: String, required: true },
  email:    { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['founder', 'collaborator', 'investor'], required: true },
  bio:      { type: String },
  profileImage: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);