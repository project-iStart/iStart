"use strict";

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance"); }

function _iterableToArray(iter) { if (Symbol.iterator in Object(iter) || Object.prototype.toString.call(iter) === "[object Arguments]") return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } }

var express = require('express');

var router = express.Router();

var auth = require('../middleware/auth');

var DiscussionThread = require('../models/DiscussionThread');

var Message = require('../models/Message');

var Notification = require('../models/Notification');

var StartupIdea = require('../models/StartupIdea'); // POST /api/discussion — create thread


router.post('/', auth, function _callee(req, res) {
  var _req$body, startupIdeaId, title, participants, idea, defaultParticipants, thread;

  return regeneratorRuntime.async(function _callee$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          _req$body = req.body, startupIdeaId = _req$body.startupIdeaId, title = _req$body.title, participants = _req$body.participants;
          _context.prev = 1;
          _context.next = 4;
          return regeneratorRuntime.awrap(StartupIdea.findById(startupIdeaId));

        case 4:
          idea = _context.sent;

          if (idea) {
            _context.next = 7;
            break;
          }

          return _context.abrupt("return", res.status(404).json({
            msg: 'Idea not found'
          }));

        case 7:
          // default participants: founder + existing team members
          defaultParticipants = [idea.founder.toString()].concat(_toConsumableArray((idea.teamMembers || []).map(function (m) {
            return m.toString();
          })));
          thread = new DiscussionThread({
            startupIdea: startupIdeaId,
            title: title,
            participants: Array.isArray(participants) && participants.length > 0 ? participants : defaultParticipants
          });
          _context.next = 11;
          return regeneratorRuntime.awrap(thread.save());

        case 11:
          res.json(thread);
          _context.next = 17;
          break;

        case 14:
          _context.prev = 14;
          _context.t0 = _context["catch"](1);
          res.status(500).json({
            msg: 'Server error'
          });

        case 17:
        case "end":
          return _context.stop();
      }
    }
  }, null, null, [[1, 14]]);
}); // GET /api/discussion/:ideaId — get threads for an idea

router.get('/:ideaId', auth, function _callee2(req, res) {
  var idea, isTeamMember, threads;
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
          isTeamMember = idea.teamMembers.map(function (m) {
            return m.toString();
          }).includes(req.user.id) || idea.founder.toString() === req.user.id;

          if (!isTeamMember) {
            _context2.next = 13;
            break;
          }

          _context2.next = 10;
          return regeneratorRuntime.awrap(DiscussionThread.find({
            startupIdea: req.params.ideaId
          }));

        case 10:
          threads = _context2.sent;
          _context2.next = 16;
          break;

        case 13:
          _context2.next = 15;
          return regeneratorRuntime.awrap(DiscussionThread.find({
            startupIdea: req.params.ideaId,
            participants: req.user.id
          }));

        case 15:
          threads = _context2.sent;

        case 16:
          res.json(threads);
          _context2.next = 22;
          break;

        case 19:
          _context2.prev = 19;
          _context2.t0 = _context2["catch"](0);
          res.status(500).json({
            msg: 'Server error'
          });

        case 22:
        case "end":
          return _context2.stop();
      }
    }
  }, null, null, [[0, 19]]);
}); // POST /api/discussion/:threadId/messages — send message

router.post('/:threadId/messages', auth, function _callee3(req, res) {
  var thread, idea, isTeamMember, isParticipant, messageData, message, recipientIds, uniqueRecipients, _i, _uniqueRecipients, rid;

  return regeneratorRuntime.async(function _callee3$(_context3) {
    while (1) {
      switch (_context3.prev = _context3.next) {
        case 0:
          _context3.prev = 0;
          _context3.next = 3;
          return regeneratorRuntime.awrap(DiscussionThread.findById(req.params.threadId));

        case 3:
          thread = _context3.sent;

          if (thread) {
            _context3.next = 6;
            break;
          }

          return _context3.abrupt("return", res.status(404).json({
            msg: 'Thread not found'
          }));

        case 6:
          _context3.next = 8;
          return regeneratorRuntime.awrap(StartupIdea.findById(thread.startupIdea));

        case 8:
          idea = _context3.sent;

          if (idea) {
            _context3.next = 11;
            break;
          }

          return _context3.abrupt("return", res.status(404).json({
            msg: 'Idea not found'
          }));

        case 11:
          isTeamMember = idea.teamMembers.map(function (m) {
            return m.toString();
          }).includes(req.user.id) || idea.founder.toString() === req.user.id;
          isParticipant = (thread.participants || []).map(function (p) {
            return p.toString();
          }).includes(req.user.id);

          if (!(!isTeamMember && !isParticipant)) {
            _context3.next = 15;
            break;
          }

          return _context3.abrupt("return", res.status(403).json({
            msg: 'Not authorized to post in this thread'
          }));

        case 15:
          messageData = {
            thread: req.params.threadId,
            sender: req.user.id,
            content: req.body.content
          };

          if (Array.isArray(req.body.attachments) && req.body.attachments.length > 0) {
            messageData.attachments = req.body.attachments;
          }

          message = new Message(messageData);
          _context3.next = 20;
          return regeneratorRuntime.awrap(message.save());

        case 20:
          // notify other participants
          recipientIds = thread.participants && thread.participants.length ? thread.participants.map(function (p) {
            return p.toString();
          }) : [idea.founder.toString()].concat(_toConsumableArray((idea.teamMembers || []).map(function (m) {
            return m.toString();
          })));
          uniqueRecipients = Array.from(new Set(recipientIds));
          _i = 0, _uniqueRecipients = uniqueRecipients;

        case 23:
          if (!(_i < _uniqueRecipients.length)) {
            _context3.next = 32;
            break;
          }

          rid = _uniqueRecipients[_i];

          if (!(rid === req.user.id)) {
            _context3.next = 27;
            break;
          }

          return _context3.abrupt("continue", 29);

        case 27:
          _context3.next = 29;
          return regeneratorRuntime.awrap(Notification.create({
            user: rid,
            message: "New message in \"".concat(thread.title || idea.title, "\""),
            type: 'message',
            refId: message._id,
            triggeredBy: req.user.id
          }));

        case 29:
          _i++;
          _context3.next = 23;
          break;

        case 32:
          res.json(message);
          _context3.next = 38;
          break;

        case 35:
          _context3.prev = 35;
          _context3.t0 = _context3["catch"](0);
          res.status(500).json({
            msg: 'Server error'
          });

        case 38:
        case "end":
          return _context3.stop();
      }
    }
  }, null, null, [[0, 35]]);
}); // GET /api/discussion/:threadId/messages — get messages

router.get('/:threadId/messages', auth, function _callee4(req, res) {
  var thread, idea, isTeamMember, isParticipant, messages;
  return regeneratorRuntime.async(function _callee4$(_context4) {
    while (1) {
      switch (_context4.prev = _context4.next) {
        case 0:
          _context4.prev = 0;
          _context4.next = 3;
          return regeneratorRuntime.awrap(DiscussionThread.findById(req.params.threadId));

        case 3:
          thread = _context4.sent;

          if (thread) {
            _context4.next = 6;
            break;
          }

          return _context4.abrupt("return", res.status(404).json({
            msg: 'Thread not found'
          }));

        case 6:
          _context4.next = 8;
          return regeneratorRuntime.awrap(StartupIdea.findById(thread.startupIdea));

        case 8:
          idea = _context4.sent;

          if (idea) {
            _context4.next = 11;
            break;
          }

          return _context4.abrupt("return", res.status(404).json({
            msg: 'Idea not found'
          }));

        case 11:
          isTeamMember = idea.teamMembers.map(function (m) {
            return m.toString();
          }).includes(req.user.id) || idea.founder.toString() === req.user.id;
          isParticipant = (thread.participants || []).map(function (p) {
            return p.toString();
          }).includes(req.user.id);

          if (!(!isTeamMember && !isParticipant)) {
            _context4.next = 15;
            break;
          }

          return _context4.abrupt("return", res.status(403).json({
            msg: 'Not authorized to view messages'
          }));

        case 15:
          _context4.next = 17;
          return regeneratorRuntime.awrap(Message.find({
            thread: req.params.threadId
          }).populate('sender', 'name profileImage role').sort({
            createdAt: 1
          }));

        case 17:
          messages = _context4.sent;
          res.json(messages);
          _context4.next = 24;
          break;

        case 21:
          _context4.prev = 21;
          _context4.t0 = _context4["catch"](0);
          res.status(500).json({
            msg: 'Server error'
          });

        case 24:
        case "end":
          return _context4.stop();
      }
    }
  }, null, null, [[0, 21]]);
});
module.exports = router;