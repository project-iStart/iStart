"use strict";

var mongoose = require('mongoose');

var _mongoMemoryServer = null;

var connectDB = function connectDB() {
  var uri, _require, MongoMemoryServer;

  return regeneratorRuntime.async(function connectDB$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          _context.prev = 0;
          uri = process.env.MONGO_URI; // Allow an explicit override to use an in-memory MongoDB for local testing

          if (!(!uri || process.env.USE_INMEMORY_DB === 'true')) {
            _context.next = 9;
            break;
          }

          console.log('Starting in-memory MongoDB for development/testing'); // lazy require to avoid adding this dependency unless needed

          _require = require('mongodb-memory-server'), MongoMemoryServer = _require.MongoMemoryServer;
          _context.next = 7;
          return regeneratorRuntime.awrap(MongoMemoryServer.create());

        case 7:
          _mongoMemoryServer = _context.sent;
          uri = _mongoMemoryServer.getUri();

        case 9:
          if (uri) {
            _context.next = 11;
            break;
          }

          throw new Error('MONGO_URI is not defined and in-memory DB failed to start');

        case 11:
          _context.next = 13;
          return regeneratorRuntime.awrap(mongoose.connect(uri, {
            serverSelectionTimeoutMS: 5000
          }));

        case 13:
          console.log('MongoDB Connected');
          _context.next = 20;
          break;

        case 16:
          _context.prev = 16;
          _context.t0 = _context["catch"](0);
          console.error('MongoDB Connection Error:', _context.t0);
          process.exit(1);

        case 20:
        case "end":
          return _context.stop();
      }
    }
  }, null, null, [[0, 16]]);
};

module.exports = connectDB;