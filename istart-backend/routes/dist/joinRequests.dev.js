"use strict";

var express = require('express');

var router = express.Router();

var auth = require('../middleware/auth');

var JoinRequest = require('../models/JoinRequest');

var StartupIdea = require('../models/StartupIdea');

var Notification = require('../models/Notification'); // POST — collaborator sends request


router.post('/', auth, function _callee(req, res) {
  var _req$body, startupIdeaId, message, existing, request, idea;

  return regeneratorRuntime.async(function _callee$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          if (!(req.user.role !== 'collaborator')) {
            _context.next = 2;
            break;
          }

          return _context.abrupt("return", res.status(403).json({
            msg: 'Only Collaborators can send join requests'
          }));

        case 2:
          _req$body = req.body, startupIdeaId = _req$body.startupIdeaId, message = _req$body.message;
          _context.prev = 3;
          _context.next = 6;
          return regeneratorRuntime.awrap(JoinRequest.findOne({
            collaborator: req.user.id,
            startupIdea: startupIdeaId,
            status: 'pending'
          }));

        case 6:
          existing = _context.sent;

          if (!existing) {
            _context.next = 9;
            break;
          }

          return _context.abrupt("return", res.status(400).json({
            msg: 'Request already sent'
          }));

        case 9:
          request = new JoinRequest({
            collaborator: req.user.id,
            startupIdea: startupIdeaId,
            message: message
          });
          _context.next = 12;
          return regeneratorRuntime.awrap(request.save());

        case 12:
          _context.next = 14;
          return regeneratorRuntime.awrap(StartupIdea.findById(startupIdeaId));

        case 14:
          idea = _context.sent;
          _context.next = 17;
          return regeneratorRuntime.awrap(Notification.create({
            user: idea.founder,
            message: "New join request received for \"".concat(idea.title, "\"."),
            type: 'join_request',
            refId: request._id
          }));

        case 17:
          res.json(request);
          _context.next = 23;
          break;

        case 20:
          _context.prev = 20;
          _context.t0 = _context["catch"](3);
          res.status(500).json({
            msg: 'Server error'
          });

        case 23:
        case "end":
          return _context.stop();
      }
    }
  }, null, null, [[3, 20]]);
}); // GET — founder views requests for a specific startup

router.get('/:ideaId', auth, function _callee2(req, res) {
  var idea, requests;
  return regeneratorRuntime.async(function _callee2$(_context2) {
    while (1) {
      switch (_context2.prev = _context2.next) {
        case 0:
          _context2.prev = 0;
          _context2.next = 3;
          return regeneratorRuntime.awrap(StartupIdea.findById(req.params.ideaId));

        case 3:
          idea = _context2.sent;

          if (idea) {
            _context2.next = 6;
            break;
          }

          return _context2.abrupt("return", res.status(404).json({
            msg: 'Idea not found'
          }));

        case 6:
          if (!(idea.founder.toString() !== req.user.id)) {
            _context2.next = 8;
            break;
          }

          return _context2.abrupt("return", res.status(403).json({
            msg: 'Not authorized'
          }));

        case 8:
          _context2.next = 10;
          return regeneratorRuntime.awrap(JoinRequest.find({
            startupIdea: req.params.ideaId
          }).populate('collaborator', 'name profileImage bio skills availability'));

        case 10:
          requests = _context2.sent;
          res.json(requests);
          _context2.next = 17;
          break;

        case 14:
          _context2.prev = 14;
          _context2.t0 = _context2["catch"](0);
          res.status(500).json({
            msg: 'Server error'
          });

        case 17:
        case "end":
          return _context2.stop();
      }
    }
  }, null, null, [[0, 14]]);
}); // PUT — founder approves or rejects

router.put('/:id', auth, function _callee3(req, res) {
  var status, request, idea;
  return regeneratorRuntime.async(function _callee3$(_context3) {
    while (1) {
      switch (_context3.prev = _context3.next) {
        case 0:
          status = req.body.status; // 'approved' or 'rejected'

          _context3.prev = 1;
          _context3.next = 4;
          return regeneratorRuntime.awrap(JoinRequest.findById(req.params.id));

        case 4:
          request = _context3.sent;

          if (request) {
            _context3.next = 7;
            break;
          }

          return _context3.abrupt("return", res.status(404).json({
            msg: 'Request not found'
          }));

        case 7:
          _context3.next = 9;
          return regeneratorRuntime.awrap(StartupIdea.findById(request.startupIdea));

        case 9:
          idea = _context3.sent;

          if (!(idea.founder.toString() !== req.user.id)) {
            _context3.next = 12;
            break;
          }

          return _context3.abrupt("return", res.status(403).json({
            msg: 'Not authorized'
          }));

        case 12:
          request.status = status;
          _context3.next = 15;
          return regeneratorRuntime.awrap(request.save());

        case 15:
          if (!(status === 'approved')) {
            _context3.next = 20;
            break;
          }

          if (idea.teamMembers.includes(request.collaborator)) {
            _context3.next = 20;
            break;
          }

          idea.teamMembers.push(request.collaborator);
          _context3.next = 20;
          return regeneratorRuntime.awrap(idea.save());

        case 20:
          _context3.next = 22;
          return regeneratorRuntime.awrap(Notification.create({
            user: request.collaborator,
            message: status === 'approved' ? "Your join request for \"".concat(idea.title, "\" was approved! You are now collaborating on this startup.") : "Your join request for \"".concat(idea.title, "\" was rejected."),
            type: 'join_request',
            refId: idea._id
          }));

        case 22:
          res.json(request);
          _context3.next = 28;
          break;

        case 25:
          _context3.prev = 25;
          _context3.t0 = _context3["catch"](1);
          res.status(500).json({
            msg: 'Server error'
          });

        case 28:
        case "end":
          return _context3.stop();
      }
    }
  }, null, null, [[1, 25]]);
}); // GET — collaborator views their join requests

router.get('/collaborator/my-requests', auth, function _callee4(req, res) {
  var requests;
  return regeneratorRuntime.async(function _callee4$(_context4) {
    while (1) {
      switch (_context4.prev = _context4.next) {
        case 0:
          if (!(req.user.role !== 'collaborator')) {
            _context4.next = 2;
            break;
          }

          return _context4.abrupt("return", res.status(403).json({
            msg: 'Only collaborators can view their requests'
          }));

        case 2:
          _context4.prev = 2;
          _context4.next = 5;
          return regeneratorRuntime.awrap(JoinRequest.find({
            collaborator: req.user.id
          }).populate('startupIdea', 'title description stage'));

        case 5:
          requests = _context4.sent;
          res.json(requests);
          _context4.next = 12;
          break;

        case 9:
          _context4.prev = 9;
          _context4.t0 = _context4["catch"](2);
          res.status(500).json({
            msg: 'Server error'
          });

        case 12:
        case "end":
          return _context4.stop();
      }
    }
  }, null, null, [[2, 9]]);
});
module.exports = router;