const DailyReport = require('../models/DailyReport');

const dailyReportRepository = {
  findById: (id) =>
    DailyReport.findById(id)
      .populate('deliveries.customerId', 'name phone address')
      .populate('emptyIn.customerId', 'name phone')
      .populate('extra.customerId', 'name phone')
      .populate('notReceived.customerId', 'name phone')
      .populate('payments.customerId', 'name phone pendingAmount')
      .populate('labourId', 'name mobile'),

  findByLabourAndDate: (labourId, date) =>
    DailyReport.findOne({ labourId, date }),

  create: (data) => DailyReport.create(data),

  update: (id, data) =>
    DailyReport.findByIdAndUpdate(id, data, { new: true, runValidators: true }),

  findByOwner: (ownerId, filter = {}) =>
    DailyReport.find({ ownerId, ...filter })
      .populate('labourId', 'name mobile')
      .sort({ date: -1, createdAt: -1 }),

  aggregateByDateRange: (ownerId, startDate, endDate) =>
    DailyReport.aggregate([
      { $match: { ownerId, status: 'submitted', date: { $gte: startDate, $lte: endDate } } },
      {
        $group: {
          _id: '$date',
          deliveries: { $sum: '$totalDelivered' },
          undelivered: { $sum: '$totalUndelivered' },
          emptyIn: { $sum: '$totalEmptyIn' },
          extra: { $sum: '$totalExtra' },
          notReceived: { $sum: '$totalNotReceived' },
          revenue: { $sum: '$totalCollectedAmount' },
        },
      },
      { $sort: { _id: 1 } },
    ]),

  aggregateTodaySummary: (ownerId, date) =>
    DailyReport.aggregate([
      { $match: { ownerId, date, status: 'submitted' } },
      {
        $group: {
          _id: null,
          totalDelivered: { $sum: '$totalDelivered' },
          totalUndelivered: { $sum: '$totalUndelivered' },
          totalEmptyIn: { $sum: '$totalEmptyIn' },
          totalExtra: { $sum: '$totalExtra' },
          totalNotReceived: { $sum: '$totalNotReceived' },
          totalCollectedAmount: { $sum: '$totalCollectedAmount' },
        },
      },
    ]),
};

module.exports = dailyReportRepository;
