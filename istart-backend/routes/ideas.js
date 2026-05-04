const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const optionalAuth = require('../middleware/optionalAuth');
const StartupIdea = require('../models/StartupIdea');
const Vote = require('../models/Vote');

// GET /api/ideas — browse all ideas
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { category, stage, search } = req.query;
    let query = {};
    if (category) query.category = category;
    if (stage) query.stage = stage;
    if (search) query.title = { $regex: search, $options: 'i' };

    const ideas = await StartupIdea.find(query)
      .populate('founder', 'name profileImage')
      .sort({ createdAt: -1 });

    let votedSet = new Set();
    let bookmarkedSet = new Set();

    if (req.user) {
      const userId = req.user.id;

      const votes = await Vote.find({
        user: userId,
        startupIdea: { $in: ideas.map(i => i._id) },
      }).select('startupIdea');
      votedSet = new Set(votes.map(v => v.startupIdea.toString()));

      bookmarkedSet = new Set(
        ideas
          .filter(i => i.bookmarkedBy.map(b => b.toString()).includes(userId))
          .map(i => i._id.toString())
      );
    }

    // Compute voteCount per idea via aggregation
    const ideaIds = ideas.map(i => i._id);
    const voteCounts = await Vote.aggregate([
      { $match: { startupIdea: { $in: ideaIds } } },
      { $group: { _id: '$startupIdea', count: { $sum: 1 } } },
    ]);
    const voteCountMap = {};
    voteCounts.forEach(v => { voteCountMap[v._id.toString()] = v.count; });

    const result = ideas.map(idea => ({
      ...idea.toObject(),
      voteCount: voteCountMap[idea._id.toString()] ?? 0,
      isVoted: votedSet.has(idea._id.toString()),
      isBookmarked: bookmarkedSet.has(idea._id.toString()),
    }));

    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/ideas/:id — single idea detail
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.id)
      .populate('founder', 'name profileImage')
      .populate('teamMembers', 'name profileImage role');
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    let isVoted = false;
    let isBookmarked = false;

    if (req.user) {
      const vote = await Vote.findOne({ user: req.user.id, startupIdea: idea._id });
      isVoted = !!vote;
      isBookmarked = idea.bookmarkedBy.map(b => b.toString()).includes(req.user.id);
    }

    const voteCount = await Vote.countDocuments({ startupIdea: idea._id });

    res.json({
      ...idea.toObject(),
      voteCount,
      isVoted,
      isBookmarked,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/ideas — create idea (Founder only)
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'founder')
    return res.status(403).json({ msg: 'Only Founders can post ideas' });
  try {
    const { title, description, problemStatement, category, stage, pitchDeckUrl } = req.body;
    const idea = new StartupIdea({
      founder: req.user.id,
      title, description, problemStatement, category, stage, pitchDeckUrl,
      teamMembers: [req.user.id],
    });
    await idea.save();
    res.json(idea);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT /api/ideas/:id — update idea (Founder only)
router.put('/:id', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.id);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });
    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    Object.assign(idea, req.body);
    await idea.save();
    res.json(idea);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// DELETE /api/ideas/:id — delete idea (Founder only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.id);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });
    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    await idea.deleteOne();
    res.json({ msg: 'Idea deleted' });
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/ideas/:id/bookmark — toggle bookmark
router.post('/:id/bookmark', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.id);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const index = idea.bookmarkedBy.map(b => b.toString()).indexOf(req.user.id);
    if (index === -1) {
      idea.bookmarkedBy.push(req.user.id);
    } else {
      idea.bookmarkedBy.splice(index, 1);
    }
    await idea.save();
    res.json({ bookmarked: index === -1 });
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;