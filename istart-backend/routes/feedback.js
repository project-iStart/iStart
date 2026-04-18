const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Feedback = require('../models/Feedback');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST /api/feedback
router.post('/', auth, async (req, res) => {
  const { startupIdeaId, category, rating, comment } = req.body;
  try {
    const idea = await StartupIdea.findById(startupIdeaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const feedback = new Feedback({
      user: req.user.id, startupIdea: startupIdeaId, category, rating, comment
    });
    await feedback.save();

    await Notification.create({
      user: idea.founder,
      message: `Your idea "${idea.title}" received new feedback.`,
      type: 'feedback',
      refId: idea._id
    });

    res.json(feedback);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/feedback/:ideaId
router.get('/:ideaId', async (req, res) => {
  try {
    const feedbacks = await Feedback.find({ startupIdea: req.params.ideaId })
      .populate('user', 'name profileImage role');
    res.json(feedbacks);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;