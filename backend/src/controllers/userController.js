const userService = require('../services/userService');
const { sendSuccess } = require('../utils/response');

const userController = {
  createLabour: async (req, res) => {
    const labour = await userService.createLabour(req.user._id, req.validated.body);
    sendSuccess(res, labour, 'Labour account created', 201);
  },

  getLabourAccounts: async (req, res) => {
    const accounts = await userService.getLabourAccounts(req.user._id);
    sendSuccess(res, accounts);
  },
};

module.exports = userController;
