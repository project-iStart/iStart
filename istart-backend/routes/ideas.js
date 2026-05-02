const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const StartupIdea = require('../models/StartupIdea');

// GET /api/ideas — browse all ideas
router.get('/', async (req, res) => {
  try {
    const { category, stage, search } = req.query;
    let query = {};
    if (category) query.category = category;
    if (stage) query.stage = stage;
    if (search) query.title = { $regex: search, $options: 'i' };

    const ideas = await StartupIdea.find(query)
      .populate('founder', 'name profileImage')
      .sort({ createdAt: -1 });
    res.json(ideas);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/ideas/:id — single idea detail
router.get('/:id', async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.id)
      .populate('founder', 'name profileImage')
      .populate('teamMembers', 'name profileImage role');
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });
    res.json(idea);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/ideas — create idea (Founder only)
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'founder') return res.status(403).json({ msg: 'Only Founders can post ideas' });
  try {
    const { title, description, problemStatement, category, stage, pitchDeckUrl } = req.body;
    const idea = new StartupIdea({
      founder: req.user.id,
      title, description, problemStatement, category, stage, pitchDeckUrl,
      teamMembers: [req.user.id]
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
    if (idea.founder.toString() !== req.user.id) return res.status(403).json({ msg: 'Not authorized' });

    const updates = req.body;
    Object.assign(idea, updates);
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
    if (idea.founder.toString() !== req.user.id) return res.status(403).json({ msg: 'Not authorized' });

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

    const index = idea.bookmarkedBy.indexOf(req.user.id);
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