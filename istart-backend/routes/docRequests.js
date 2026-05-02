const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const DocRequest = require('../models/DocRequest');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST — investor sends request
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'investor')
    return res.status(403).json({ msg: 'Only Investors can send doc requests' });

  const { startupIdeaId, requestMessage } = req.body;
  try {
    const request = new DocRequest({ investor: req.user.id, startupIdea: startupIdeaId, requestMessage });
    await request.save();

    const idea = await StartupIdea.findById(startupIdeaId);
    await Notification.create({
      user: idea.founder,
      message: `An investor requested documents for "${idea.title}".`,
      type: 'doc_request',
      refId: request._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT — founder responds
router.put('/:id', auth, async (req, res) => {
  const { responseMessage, fileUrl } = req.body;
  try {
    const request = await DocRequest.findById(req.params.id).populate('investor');
    if (!request) return res.status(404).json({ msg: 'Request not found' });

    request.responseMessage = responseMessage;
    request.fileUrl = fileUrl;
    request.status = 'responded';
    await request.save();

    const idea = await StartupIdea.findById(request.startupIdea);

    // Notify the investor that founder responded  ← added
    await Notification.create({
      user: request.investor._id,
      message: `The founder responded to your document request for "${idea.title}".`,
      type: 'doc_request',
      refId: request._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET — founder views all requests
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const requests = await DocRequest.find({ startupIdea: req.params.ideaId })
      .populate('investor', 'name email profileImage');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;