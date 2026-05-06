const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Feedback = require('../models/Feedback');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST /api/feedback
router.post('/', auth, async (req, res) => {
  const { category, rating, comment } = req.body;
  const startupIdea = req.body.startupIdea || req.body.startupIdeaId || req.body.idea;

  try {
    const idea = await StartupIdea.findById(startupIdea);
    if (!idea) return res.status(404).json({ message: 'Idea not found' });

    // Block founder from giving feedback on their own idea
    if (idea.founder.toString() === req.user.id) {
      return res.status(403).json({ message: 'You cannot give feedback on your own idea.' });
    }

    const feedback = new Feedback({
      user: req.user.id,
      startupIdea,
      category,
      rating,
      comment,
    });
    await feedback.save();

    await Notification.create({
      user: idea.founder,
      message: `Your idea "${idea.title}" received new feedback.`,
      type: 'feedback',
      refId: idea._id,
      triggeredBy: req.user.id,
    });

    res.status(201).json(feedback);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/feedback/:ideaId
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const feedbacks = await Feedback.find({ startupIdea: req.params.ideaId })
      .populate('user', 'name profileImage role');
    res.json(feedbacks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;