const User = require('../models/User');

const userRepository = {
  findByMobile: (mobile) => User.findOne({ mobile }),
  findById: (id) => User.findById(id),
  create: (data) => User.create(data),
  findLabourByOwner: (ownerId) =>
    User.find({ role: 'labour', createdBy: ownerId, active: true }).sort({ name: 1 }),
};

module.exports = userRepository;
