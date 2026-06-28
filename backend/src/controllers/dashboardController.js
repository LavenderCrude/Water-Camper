const dashboardService = require('../services/dashboardService');
const { sendSuccess } = require('../utils/response');

const dashboardController = {
  getSummary: async (req, res) => {
    const { date } = req.validated.query;
    const summary = await dashboardService.getSummary(req.user._id, date);
    sendSuccess(res, summary);
  },

  getAnalytics: async (req, res) => {
    const { range } = req.validated.query;
    const analytics = await dashboardService.getAnalytics(req.user._id, range || '7d');
    sendSuccess(res, analytics);
  },

  getPaymentHistory: async (req, res) => {
    const { date } = req.validated.query;
    const payments = await dashboardService.getPaymentHistory(req.user._id, date);
    sendSuccess(res, payments);
  },
};

module.exports = dashboardController;
