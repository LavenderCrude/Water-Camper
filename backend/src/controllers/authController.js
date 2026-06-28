const authService = require('../services/authService');
const { sendSuccess } = require('../utils/response');

const authController = {
  login: async (req, res) => {
    const { mobile, password } = req.validated.body;
    const result = await authService.login(mobile, password);
    sendSuccess(res, result, 'Login successful');
  },

  logout: async (req, res) => {
    sendSuccess(res, null, 'Logout successful');
  },

  me: async (req, res) => {
    const user = await authService.getProfile(req.user._id);
    sendSuccess(res, user);
  },
};

module.exports = authController;
