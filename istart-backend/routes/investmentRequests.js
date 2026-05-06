const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const InvestmentRequest = require('../models/InvestmentRequest');
const StartupIdea = require('../models/StartupIdea');
const Notification = require('../models/Notification');

// POST — investor sends funding request
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'investor')
    return res.status(403).json({ msg: 'Only Investors can send funding requests' });

  const { startupIdeaId, fundingAmount, message } = req.body;
  try {
    const existing = await InvestmentRequest.findOne({ 
      investor: req.user.id, 
      startupIdea: startupIdeaId,
      status: 'pending'
    });
    if (existing) return res.status(400).json({ msg: 'Request already sent' });

    const request = new InvestmentRequest({ 
      investor: req.user.id, 
      startupIdea: startupIdeaId, 
      fundingAmount,
      message 
    });
    await request.save();

    const idea = await StartupIdea.findById(startupIdeaId);
    await Notification.create({
      user: idea.founder,
      message: `New funding request received from an investor for "${idea.title}".`,
      type: 'investment_request', 
      refId: request._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET — founder views pending investment requests for a startup
router.get('/:ideaId', auth, async (req, res) => {
  try {
    const idea = await StartupIdea.findById(req.params.ideaId);
    if (!idea) return res.status(404).json({ msg: 'Idea not found' });

    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    const requests = await InvestmentRequest.find({ startupIdea: req.params.ideaId })
      .populate('investor', 'name profileImage investmentFocus portfolioLink');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT — founder approves or rejects investment request
router.put('/:id', auth, async (req, res) => {
  const { status } = req.body; // 'approved' or 'rejected'
  try {
    const request = await InvestmentRequest.findById(req.params.id);
    if (!request) return res.status(404).json({ msg: 'Request not found' });

    const idea = await StartupIdea.findById(request.startupIdea);
    if (idea.founder.toString() !== req.user.id)
      return res.status(403).json({ msg: 'Not authorized' });

    request.status = status;
    await request.save();

    if (status === 'approved') {
      // Check if investor is already in the list
      if (!idea.approvedInvestors.includes(request.investor)) {
        idea.approvedInvestors.push(request.investor);
        await idea.save();
      }
    }

    // Notify the investor of the decision
    await Notification.create({
      user: request.investor,
      message: status === 'approved'
        ? `Your funding request for "${idea.title}" was approved! You can now invest in this startup.`
        : `Your funding request for "${idea.title}" was rejected.`,
      type: 'investment_request',
      refId: idea._id
    });

    res.json(request);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET — investor views their funding requests
router.get('/investor/my-requests', auth, async (req, res) => {
  if (req.user.role !== 'investor')
    return res.status(403).json({ msg: 'Only investors can view their requests' });

  try {
    const requests = await InvestmentRequest.find({ investor: req.user.id })
      .populate('startupIdea', 'title description stage');
    res.json(requests);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
