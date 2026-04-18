const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Vote = require('../models/Vote');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST /api/votes — cast or change vote
router.post('/', auth, async (req, res) => {
  const { startupIdeaId, type } = req.body;
  try {
    const idea = await StartupIdea.findById(startupIdeaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });
    if (idea.founder.toString() === req.user.id) return res.status(403).json({ msg: 'Cannot vote on your own idea' });

    let vote = await Vote.findOne({ user: req.user.id, startupIdea: startupIdeaId });
    if (vote) {
      vote.type = type;
      await vote.save();
    } else {
      vote = new Vote({ user: req.user.id, startupIdea: startupIdeaId, type });
      await vote.save();
    }

    // Update community score
    const upvotes = await Vote.countDocuments({ startupIdea: startupIdeaId, type: 'upvote' });
    const downvotes = await Vote.countDocuments({ startupIdea: startupIdeaId, type: 'downvote' });
    idea.communityScore = upvotes - downvotes;
    await idea.save();

    // Notify founder
    await Notification.create({
      user: idea.founder,
      message: `Your idea "${idea.title}" received a new vote.`,
      type: 'vote',
      refId: idea._id
    });

    res.json({ communityScore: idea.communityScore });
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;