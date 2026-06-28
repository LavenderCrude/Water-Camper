const Payment = require('../models/Payment');

const paymentRepository = {
  createMany: (payments) => Payment.insertMany(payments),
  findByCustomer: (customerId) =>
    Payment.find({ customerId }).sort({ date: -1 }).populate('labourId', 'name'),
  findByOwner: (ownerId, date) => {
    const query = { ownerId };
    if (date) query.date = date;
    return Payment.find(query)
      .sort({ createdAt: -1 })
      .populate('customerId', 'name phone')
      .populate('labourId', 'name');
  },
};

module.exports = paymentRepository;
