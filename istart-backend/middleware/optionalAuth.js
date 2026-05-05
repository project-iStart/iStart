const jwt = require('jsonwebtoken');

// Like auth.js but does not reject unauthenticated requests.
// It attaches req.user when a valid token is present.
module.exports = (req, res, next) => {
  const authHeader = req.header('Authorization');
  const token = authHeader?.replace('Bearer ', '') || req.header('x-auth-token');

  if (!token) {
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.user;
  } catch (_) {
    // Ignore invalid tokens and continue as a guest request.
  }

  next();
};
