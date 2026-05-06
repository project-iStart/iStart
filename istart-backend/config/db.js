const mongoose = require('mongoose');

let _mongoMemoryServer = null;

const connectDB = async () => {
  try {
    let uri = process.env.MONGO_URI;

    // Allow an explicit override to use an in-memory MongoDB for local testing
    if (!uri || process.env.USE_INMEMORY_DB === 'true') {
      console.log('Starting in-memory MongoDB for development/testing');
      // lazy require to avoid adding this dependency unless needed
      const { MongoMemoryServer } = require('mongodb-memory-server');
      _mongoMemoryServer = await MongoMemoryServer.create();
      uri = _mongoMemoryServer.getUri();
    }

    if (!uri) {
      throw new Error('MONGO_URI is not defined and in-memory DB failed to start');
    }

    await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 5000,
    });

    console.log('MongoDB Connected');
  } catch (err) {
    console.error('MongoDB Connection Error:', err);
    process.exit(1);
  }
};

module.exports = connectDB;