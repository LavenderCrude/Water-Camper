const ApiError = require('../utils/ApiError');
const userRepository = require('../repositories/userRepository');

const userService = {
  createLabour: async (ownerId, data) => {
    const existing = await userRepository.findByMobile(data.mobile);
    if (existing) throw new ApiError(409, 'Mobile number already registered');

    return userRepository.create({
      ...data,
      role: 'labour',
      createdBy: ownerId,
    });
  },

  getLabourAccounts: async (ownerId) => {
    return userRepository.findLabourByOwner(ownerId);
  },
};

module.exports = userService;
