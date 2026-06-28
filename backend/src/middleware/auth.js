const jwt = require('jsonwebtoken');
const ApiError = require('../utils/ApiError');
const User = require('../models/User');
const { jwtSecret } = require('../config/env');

const authenticate = async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return next(new ApiError(401, 'Authentication required'));
  }

  try {
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const user = await User.findById(decoded.id);
    if (!user || !user.active) {
      return next(new ApiError(401, 'Invalid or inactive user'));
    }
    req.user = user;
    next();
  } catch {
    next(new ApiError(401, 'Invalid token'));
  }
};

module.exports = authenticate;
