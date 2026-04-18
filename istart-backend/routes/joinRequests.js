const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const JoinRequest = require('../models/JoinRequest');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST /api/join-requests — collaborator sends request
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'Collaborator') return res.status(403).json({ msg: 'Only Collaborators can send join requests' });
  const { startupIdeaId, message } = req.body;
  try {
    const existing = await JoinRequest.findOne({ collaborator: req.user.id, startupIdea: startupIdeaId });
    if (existing) return res.status(400).json({ msg: 'Request already sent' });

    const request = new JoinRequest({ collaborator: req.user.id, startupIdea: startupIdeaId, message });
    await request.save();

    const idea = await StartupIdea.findById(startupIdeaId);
    await Notification.create({
      user: idea.founder,
      message: `New join request for "${idea.title}".`,
      type: 'joinRequest',
      refId: request._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/join-requests/:ideaId — founder views requests
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const requests = await JoinRequest.find({ startupIdea: req.params.ideaId })
      .populate('collaborator', 'name profileImage bio');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT /api/join-requests/:id — approve or reject
router.put('/:id', auth, async (req, res) => {
  const { status } = req.body; // 'approved' or 'rejected'
  try {
    const request = await JoinRequest.findById(req.params.id);
    if (!request) return res.status(404).json({ msg: 'Request not found' });

    const idea = await StartupIdea.findById(request.startupIdea);
    if (idea.founder.toString() !== req.user.id) return res.status(403).json({ msg: 'Not authorized' });

    request.status = status;
    await request.save();

    if (status === 'approved') {
      idea.teamMembers.push(request.collaborator);
      await idea.save();
    }

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;