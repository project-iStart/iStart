const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const JoinRequest = require('../models/JoinRequest');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST — collaborator sends request
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'collaborator')
    return res.status(403).json({ msg: 'Only Collaborators can send join requests' });

  const { startupIdeaId, message } = req.body;
  try {
    const idea = await StartupIdea.findById(startupIdeaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    const existing = await JoinRequest.findOne({ 
      collaborator: req.user.id, 
      startupIdea: startupIdeaId,
      status: 'pending'
    });
    if (existing) return res.status(400).json({ msg: 'Request already sent' });

    const request = new JoinRequest({ collaborator: req.user.id, startupIdea: startupIdeaId, message });
    await request.save();

    await Notification.create({
      user: idea.founder,
      message: `New join request received for "${idea.title}".`,
      type: 'join_request', 
      refId: request._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET — founder views requests for a specific startup
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.ideaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    const requests = await JoinRequest.find({ startupIdea: req.params.ideaId })
      .populate('collaborator', 'name profileImage bio skills availability');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT — founder approves or rejects
router.put('/:id', auth, async (req, res) => {
  const { status } = req.body; // 'approved' or 'rejected'
  try {
    const request = await JoinRequest.findById(req.params.id);
    if (!request) return res.status(404).json({ msg: 'Request not found' });

    const idea = await StartupIdea.findById(request.startupIdea);
    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    request.status = status;
    await request.save();

    if (status === 'approved') {
      // Check if collaborator is already in the team
      if (!idea.teamMembers.includes(request.collaborator)) {
        idea.teamMembers.push(request.collaborator);
        await idea.save();
      }
    }

    // Notify the collaborator of the decision
    await Notification.create({
      user: request.collaborator,
      message: status === 'approved'
        ? `Your join request for "${idea.title}" was approved! You are now collaborating on this startup.`
        : `Your join request for "${idea.title}" was rejected.`,
      type: 'join_request',
      refId: idea._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET — collaborator views their join requests
router.get('/collaborator/my-requests', auth, async (req, res) => {
  if (req.user.role !== 'collaborator')
    return res.status(403).json({ msg: 'Only collaborators can view their requests' });

  try {
    const requests = await JoinRequest.find({ collaborator: req.user.id })
      .populate('startupIdea', 'title description stage');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;