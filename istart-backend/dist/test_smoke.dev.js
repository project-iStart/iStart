"use strict";

var fs = require('fs');

var base = 'http://localhost:5000';
var outdir = 's:/Projects/iStart/istart-backend/test_output';
if (!fs.existsSync(outdir)) fs.mkdirSync(outdir, {
  recursive: true
});

function run() {
  var r1, founder, r2, collab, r3, investor, founderToken, r4, idea, collabToken, participants, r5, thread, r6, msg, r7, notifs;
  return regeneratorRuntime.async(function run$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          _context.prev = 0;
          console.log('Registering founder...');
          _context.next = 4;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/auth/register"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              name: 'Founder',
              email: 'founder@example.com',
              password: 'pass123',
              role: 'founder'
            })
          }));

        case 4:
          r1 = _context.sent;
          _context.next = 7;
          return regeneratorRuntime.awrap(r1.json());

        case 7:
          founder = _context.sent;
          fs.writeFileSync("".concat(outdir, "/founder.json"), JSON.stringify(founder, null, 2));
          console.log('Registering collaborator...');
          _context.next = 12;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/auth/register"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              name: 'Collab',
              email: 'collab@example.com',
              password: 'pass123',
              role: 'collaborator'
            })
          }));

        case 12:
          r2 = _context.sent;
          _context.next = 15;
          return regeneratorRuntime.awrap(r2.json());

        case 15:
          collab = _context.sent;
          fs.writeFileSync("".concat(outdir, "/collab.json"), JSON.stringify(collab, null, 2));
          console.log('Registering investor...');
          _context.next = 20;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/auth/register"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              name: 'Investor',
              email: 'investor@example.com',
              password: 'pass123',
              role: 'investor'
            })
          }));

        case 20:
          r3 = _context.sent;
          _context.next = 23;
          return regeneratorRuntime.awrap(r3.json());

        case 23:
          investor = _context.sent;
          fs.writeFileSync("".concat(outdir, "/investor.json"), JSON.stringify(investor, null, 2));
          console.log('Creating idea as founder...');
          founderToken = founder.token;
          _context.next = 29;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/ideas"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + founderToken
            },
            body: JSON.stringify({
              title: 'Smoke Test Idea',
              description: 'Smoke test'
            })
          }));

        case 29:
          r4 = _context.sent;
          _context.next = 32;
          return regeneratorRuntime.awrap(r4.json());

        case 32:
          idea = _context.sent;
          fs.writeFileSync("".concat(outdir, "/idea.json"), JSON.stringify(idea, null, 2));
          console.log('Creating common thread (founder+collab+investor)');
          collabToken = collab.token;
          participants = [founder.user.id, collab.user.id, investor.user.id];
          _context.next = 39;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/discussion"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + collabToken
            },
            body: JSON.stringify({
              startupIdeaId: idea._id,
              title: 'Common Thread',
              participants: participants
            })
          }));

        case 39:
          r5 = _context.sent;
          _context.next = 42;
          return regeneratorRuntime.awrap(r5.json());

        case 42:
          thread = _context.sent;
          fs.writeFileSync("".concat(outdir, "/thread.json"), JSON.stringify(thread, null, 2));
          console.log('Posting a message as collaborator...');
          _context.next = 47;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/discussion/").concat(thread._id, "/messages"), {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + collabToken
            },
            body: JSON.stringify({
              content: 'Hello from collaborator'
            })
          }));

        case 47:
          r6 = _context.sent;
          _context.next = 50;
          return regeneratorRuntime.awrap(r6.json());

        case 50:
          msg = _context.sent;
          fs.writeFileSync("".concat(outdir, "/message.json"), JSON.stringify(msg, null, 2));
          console.log('Fetching founder notifications...');
          _context.next = 55;
          return regeneratorRuntime.awrap(fetch("".concat(base, "/api/notifications"), {
            headers: {
              Authorization: 'Bearer ' + founderToken
            }
          }));

        case 55:
          r7 = _context.sent;
          _context.next = 58;
          return regeneratorRuntime.awrap(r7.json());

        case 58:
          notifs = _context.sent;
          fs.writeFileSync("".concat(outdir, "/notifications.json"), JSON.stringify(notifs, null, 2));
          console.log('Smoke test complete. Outputs written to', outdir);
          _context.next = 66;
          break;

        case 63:
          _context.prev = 63;
          _context.t0 = _context["catch"](0);
          console.error('Smoke test error:', _context.t0);

        case 66:
        case "end":
          return _context.stop();
      }
    }
  }, null, null, [[0, 63]]);
}

run();