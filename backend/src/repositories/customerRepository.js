const Customer = require('../models/Customer');

const customerRepository = {
  create: (data) => Customer.create(data),
  findById: (id) => Customer.findById(id),
  findByOwner: (ownerId, filter = {}) =>
    Customer.find({ ownerId, ...filter }).sort({ name: 1 }),
  search: (ownerId, search, active) => {
    const query = { ownerId };
    if (active !== undefined) query.active = active === 'true';
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
        { address: { $regex: search, $options: 'i' } },
      ];
    }
    return Customer.find(query).sort({ name: 1 });
  },
  update: (id, data) => Customer.findByIdAndUpdate(id, data, { new: true, runValidators: true }),
  delete: (id) => Customer.findByIdAndUpdate(id, { active: false }, { new: true }),
  sumPendingAmount: (ownerId) =>
    Customer.aggregate([
      { $match: { ownerId: ownerId, active: true } },
      { $group: { _id: null, total: { $sum: '$pendingAmount' } } },
    ]),
  countActive: (ownerId) => Customer.countDocuments({ ownerId, active: true }),
  adjustPendingAmount: (id, delta) =>
    Customer.findByIdAndUpdate(
      id,
      [{ $set: { pendingAmount: { $max: [0, { $add: ['$pendingAmount', delta] }] } } }],
      { new: true }
    ),
};

module.exports = customerRepository;
