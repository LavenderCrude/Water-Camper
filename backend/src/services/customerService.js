const ApiError = require('../utils/ApiError');
const customerRepository = require('../repositories/customerRepository');

const customerService = {
  create: async (ownerId, data) => {
    return customerRepository.create({
      ...data,
      ownerId,
      pendingAmount: data.pendingAmount || 0,
    });
  },

  getAll: async (ownerId, search, active) => {
    return customerRepository.search(ownerId, search, active);
  },

  getById: async (ownerId, id) => {
    const customer = await customerRepository.findById(id);
    if (!customer || customer.ownerId.toString() !== ownerId.toString()) {
      throw new ApiError(404, 'Customer not found');
    }
    return customer;
  },

  update: async (ownerId, id, data) => {
    await customerService.getById(ownerId, id);
    return customerRepository.update(id, data);
  },

  updateStatus: async (ownerId, id, active) => {
    await customerService.getById(ownerId, id);

    return customerRepository.update(id, {
      active,
    });
  },

  delete: async (ownerId, id) => {
    await customerService.getById(ownerId, id);
    return customerRepository.delete(id);
  },

  getForLabour: async (ownerId) => {
    return customerRepository.findByOwner(ownerId, { active: true });
  },
};

module.exports = customerService;
