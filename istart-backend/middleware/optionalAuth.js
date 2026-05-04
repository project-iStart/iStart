const jwt = require('jsonwebtoken');

// Like auth.js but doesn't reject unauthenticated requests —
// simply attaches req.user if a valid token is present.
module.exports = (req, res, next) => {
  const token = req.header('x-auth-token');
  if (!token) return next(); // no token — continue as guest

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.user;
  } catch {
    // invalid token — continue as guest
  }
  next();
};