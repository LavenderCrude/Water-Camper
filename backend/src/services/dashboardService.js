const customerRepository = require('../repositories/customerRepository');
const dailyReportRepository = require('../repositories/dailyReportRepository');
const paymentRepository = require('../repositories/paymentRepository');

const getTodayDate = () => new Date().toISOString().split('T')[0];

const getDateRange = (range) => {
  const end = new Date();
  const start = new Date();
  if (range === '30d') {
    start.setDate(start.getDate() - 29);
  } else {
    start.setDate(start.getDate() - 6);
  }
  return {
    startDate: start.toISOString().split('T')[0],
    endDate: end.toISOString().split('T')[0],
  };
};

const dashboardService = {
  getSummary: async (ownerId, date) => {
    const targetDate = date || getTodayDate();
    const [totalCustomers, pendingResult, todayResult] = await Promise.all([
      customerRepository.countActive(ownerId),
      customerRepository.sumPendingAmount(ownerId),
      dailyReportRepository.aggregateTodaySummary(ownerId, targetDate),
    ]);

    const today = todayResult[0] || {
      totalDelivered: 0,
      totalUndelivered: 0,
      totalEmptyIn: 0,
      totalExtra: 0,
      totalNotReceived: 0,
      totalCollectedAmount: 0,
    };

    return {
      totalCustomers,
      todayDeliveries: today.totalDelivered,
      undeliveredCount: today.totalUndelivered,
      emptyCampersReceived: today.totalEmptyIn,
      extraCampers: today.totalExtra,
      notReceivedCampers: today.totalNotReceived,
      todayCollection: today.totalCollectedAmount,
      totalPendingAmount: pendingResult[0]?.total || 0,
      date: targetDate,
    };
  },

  getAnalytics: async (ownerId, range = '7d') => {
    const { startDate, endDate } = getDateRange(range);
    const chartData = await dailyReportRepository.aggregateByDateRange(
      ownerId,
      startDate,
      endDate
    );

    return {
      range,
      startDate,
      endDate,
      dailyDeliveries: chartData.map((d) => ({ date: d._id, count: d.deliveries })),
      weeklyDeliveries: chartData,
      revenueTrend: chartData.map((d) => ({ date: d._id, amount: d.revenue })),
      pendingTrend: [],
    };
  },

  getPaymentHistory: async (ownerId, date) => {
    return paymentRepository.findByOwner(ownerId, date);
  },
};

module.exports = dashboardService;
