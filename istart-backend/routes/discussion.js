const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const DiscussionThread = require('../models/DiscussionThread');
const Message = require('../models/Message');
const StartupIdea = require('../models/StartupIdea');

// POST /api/discussion — create thread
router.post('/', auth, async (req, res) => {
  const { startupIdeaId, title } = req.body;
  try {
    const thread = new DiscussionThread({ startupIdea: startupIdeaId, title });
    await thread.save();
    res.json(thread);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/discussion/:ideaId — get threads for an idea
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.ideaId);
    if (!idea.teamMembers.map(m => m.toString()).includes(req.user.id))
      return res.status(403).json({ msg: 'Team members only' });

    const threads = await DiscussionThread.find({ startupIdea: req.params.ideaId });
    res.json(threads);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/discussion/:threadId/messages — send message
router.post('/:threadId/messages', auth, async (req, res) => {
  try {
    const message = new Message({
      thread: req.params.threadId,
      sender: req.user.id,
      content: req.body.content
    });
    await message.save();
    res.json(message);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/discussion/:threadId/messages — get messages
router.get('/:threadId/messages', auth, async (req, res) => {
  try {
    const messages = await Message.find({ thread: req.params.threadId })
      .populate('sender', 'name profileImage role')
      .sort({ createdAt: 1 });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;