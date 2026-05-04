const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Vote = require('../models/Vote');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST /api/votes — toggle upvote on/off
router.post('/', auth, async (req, res) => {
  const { ideaId } = req.body;
  try {
    const idea = await StartupIdea.findById(ideaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    if (idea.founder.toString() === req.user.id)
      return res.status(403).json({ msg: 'Cannot vote on your own idea' });

    const existing = await Vote.findOne({ user: req.user.id, startupIdea: ideaId });

    if (existing) {
      // Already voted → remove vote (toggle off), no notification
      await existing.deleteOne();
    } else {
      // First time voting → create vote
      await Vote.create({ user: req.user.id, startupIdea: ideaId, type: 'upvote' });

      // Check if this user has ever voted on this idea before
      // (i.e. this is truly the first upvote ever from this user)
      const previousVoteCount = await Vote.countDocuments({
        user: req.user.id,
        startupIdea: ideaId,
      });

      // previousVoteCount is 1 now (just created) — meaning this IS the first vote
      // Fire notification only once per user per idea
      const alreadyNotified = await Notification.findOne({
        user: idea.founder,
        type: 'vote',
        refId: ideaId,
        triggeredBy: req.user.id,
      });

      if (!alreadyNotified) {
        await Notification.create({
          user: idea.founder,
          message: `Your idea "${idea.title}" received an upvote!`,
          type: 'vote',
          refId: idea._id,
          triggeredBy: req.user.id,
        });
      }
    }

    // Recalculate community score
    const voteCount = await Vote.countDocuments({ startupIdea: ideaId });
    idea.communityScore = voteCount;
    await idea.save();

    res.json({ voteCount, isVoted: !existing });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;