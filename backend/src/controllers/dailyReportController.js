const dailyReportService = require('../services/dailyReportService');
const { sendSuccess } = require('../utils/response');

const dailyReportController = {
  getToday: async (req, res) => {
    const report = await dailyReportService.getOrCreateToday(req.user);
    sendSuccess(res, report);
  },

  setFilledOut: async (req, res) => {
    const report = await dailyReportService.setFilledOut(
      req.user,
      req.validated.params.id,
      req.validated.body.filledOut
    );
    sendSuccess(res, report, 'Filled out count updated');
  },

  markDelivery: async (req, res) => {
    const report = await dailyReportService.markDelivery(
      req.user,
      req.validated.params.id,
      req.validated.body
    );
    sendSuccess(res, report, 'Delivery updated');
  },

  updateEmptyIn: async (req, res) => {
    const report = await dailyReportService.updateQuantity(
      req.user,
      req.validated.params.id,
      'emptyIn',
      req.validated.body.customerId,
      req.validated.body.delta
    );
    sendSuccess(res, report, 'Empty in updated');
  },

  updateExtra: async (req, res) => {
    const report = await dailyReportService.updateQuantity(
      req.user,
      req.validated.params.id,
      'extra',
      req.validated.body.customerId,
      req.validated.body.delta
    );
    sendSuccess(res, report, 'Extra camper updated');
  },

  updateNotReceived: async (req, res) => {
    const report = await dailyReportService.updateQuantity(
      req.user,
      req.validated.params.id,
      'notReceived',
      req.validated.body.customerId,
      req.validated.body.delta
    );
    sendSuccess(res, report, 'Not received updated');
  },

  addPayment: async (req, res) => {
    const report = await dailyReportService.addPayment(
      req.user,
      req.validated.params.id,
      req.validated.body
    );
    sendSuccess(res, report, 'Payment recorded');
  },

  submit: async (req, res) => {
    const report = await dailyReportService.submit(req.user, req.validated.params.id);
    sendSuccess(res, report, 'Daily report submitted');
  },

  getReports: async (req, res) => {
    const { date, labourId } = req.validated.query;
    const reports = await dailyReportService.getReports(req.user._id, { date, labourId });
    sendSuccess(res, reports);
  },

  getById: async (req, res) => {
    const report = await dailyReportService.getReportById(req.user, req.validated.params.id);
    sendSuccess(res, report);
  },
};

module.exports = dailyReportController;
