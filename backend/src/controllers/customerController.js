const customerService = require('../services/customerService');
const { sendSuccess } = require('../utils/response');

const customerController = {
  create: async (req, res) => {
    const customer = await customerService.create(req.user._id, req.validated.body);
    sendSuccess(res, customer, 'Customer created', 201);
  },

  getAll: async (req, res) => {
    const { search, active } = req.validated.query;
    const customers = await customerService.getAll(req.user._id, search, active);
    sendSuccess(res, customers);
  },

  getById: async (req, res) => {
    const customer = await customerService.getById(req.user._id, req.validated.params.id);
    sendSuccess(res, customer);
  },

  update: async (req, res) => {
    const customer = await customerService.update(
      req.user._id,
      req.validated.params.id,
      req.validated.body
    );
    sendSuccess(res, customer, 'Customer updated');
  },

  delete: async (req, res) => {
    const customer = await customerService.delete(req.user._id, req.validated.params.id);
    sendSuccess(res, customer, 'Customer deactivated');
  },

  getForLabour: async (req, res) => {
    const ownerId = req.user.createdBy || req.user._id;
    const customers = await customerService.getForLabour(ownerId);
    sendSuccess(res, customers);
  },
};

module.exports = customerController;
