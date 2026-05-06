const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const DiscussionThread = require('../models/DiscussionThread');
const Message = require('../models/Message');
const Notification = require('../models/Notification');
const StartupIdea = require('../models/StartupIdea');

// POST /api/discussion — create thread
router.post('/', auth, async (req, res) => {
  const { startupIdeaId, title, participants } = req.body;
  try {
    const idea = await StartupIdea.findById(startupIdeaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    // default participants: founder + existing team members
    const defaultParticipants = [idea.founder.toString(), ...(idea.teamMembers || []).map(m => m.toString())];

    const thread = new DiscussionThread({
      startupIdea: startupIdeaId,
      title,
      participants: Array.isArray(participants) && participants.length > 0
        ? participants
        : defaultParticipants,
    });
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
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const isTeamMember = idea.teamMembers.map(m => m.toString()).includes(req.user.id) || idea.founder.toString() === req.user.id;

    let threads;
    if (isTeamMember) {
      // founders and team members can see all threads for the idea
      threads = await DiscussionThread.find({ startupIdea: req.params.ideaId });
    } else {
      // others (e.g., investors or external collaborators) only see threads they are participants of
      threads = await DiscussionThread.find({ startupIdea: req.params.ideaId, participants: req.user.id });
    }

    res.json(threads);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/discussion/:threadId/messages — send message
router.post('/:threadId/messages', auth, async (req, res) => {
  try {
    const thread = await DiscussionThread.findById(req.params.threadId);
    if (!thread) return res.status(404).json({ msg: 'Thread not found' });

    const idea = await StartupIdea.findById(thread.startupIdea);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const isTeamMember = idea.teamMembers.map(m => m.toString()).includes(req.user.id) || idea.founder.toString() === req.user.id;
    const isParticipant = (thread.participants || []).map(p => p.toString()).includes(req.user.id);

    if (!isTeamMember && !isParticipant) return res.status(403).json({ msg: 'Not authorized to post in this thread' });

    const messageData = {
      thread: req.params.threadId,
      sender: req.user.id,
      content: req.body.content,
    };

    if (Array.isArray(req.body.attachments) && req.body.attachments.length > 0) {
      messageData.attachments = req.body.attachments;
    }

    const message = new Message(messageData);
    await message.save();

    // notify other participants
    const recipientIds = (thread.participants && thread.participants.length)
      ? thread.participants.map(p => p.toString())
      : [idea.founder.toString(), ...(idea.teamMembers || []).map(m => m.toString())];

    const uniqueRecipients = Array.from(new Set(recipientIds));
    for (const rid of uniqueRecipients) {
      if (rid === req.user.id) continue; // don't notify sender
      await Notification.create({
        user: rid,
        message: `New message in "${thread.title || idea.title}"`,
        type: 'message',
        refId: message._id,
        triggeredBy: req.user.id,
      });
    }

    res.json(message);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/discussion/:threadId/messages — get messages
router.get('/:threadId/messages', auth, async (req, res) => {
  try {
    const thread = await DiscussionThread.findById(req.params.threadId);
    if (!thread) return res.status(404).json({ msg: 'Thread not found' });

    const idea = await StartupIdea.findById(thread.startupIdea);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const isTeamMember = idea.teamMembers.map(m => m.toString()).includes(req.user.id) || idea.founder.toString() === req.user.id;
    const isParticipant = (thread.participants || []).map(p => p.toString()).includes(req.user.id);
    if (!isTeamMember && !isParticipant) return res.status(403).json({ msg: 'Not authorized to view messages' });

    const messages = await Message.find({ thread: req.params.threadId })
      .populate('sender', 'name profileImage role')
      .sort({ createdAt: 1 });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;