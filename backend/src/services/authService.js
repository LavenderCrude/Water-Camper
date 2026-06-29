const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const ApiError = require('../utils/ApiError');
const userRepository = require('../repositories/userRepository');
const { jwtSecret, jwtExpiresIn } = require('../config/env');

const authService = {
  register: async ({ name, mobile, password }) => {
    const existingUser = await userRepository.findByMobile(mobile);

    if (existingUser) {
      throw new ApiError(400, 'Mobile number already registered');
    }

    const user = await userRepository.create({
      name,
      mobile,
      password,
      role: 'owner',
      active: true,
    });

    return user;
  },
  login: async (mobile, password) => {
    const user = await userRepository.findByMobile(mobile);
    if (!user || !user.active) {
      throw new ApiError(401, 'Invalid mobile or password');
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw new ApiError(401, 'Invalid mobile or password');
    }

    const token = jwt.sign({ id: user._id, role: user.role }, jwtSecret, {
      expiresIn: jwtExpiresIn,
    });

    return { user, token };
  },

  getProfile: async (userId) => {
    const user = await userRepository.findById(userId);
    if (!user) throw new ApiError(404, 'User not found');
    return user;
  },
};

module.exports = authService;
