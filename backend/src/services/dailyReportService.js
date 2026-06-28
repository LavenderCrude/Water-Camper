const ApiError = require('../utils/ApiError');
const dailyReportRepository = require('../repositories/dailyReportRepository');
const customerRepository = require('../repositories/customerRepository');
const paymentRepository = require('../repositories/paymentRepository');

const getTodayDate = () => new Date().toISOString().split('T')[0];

const getOwnerIdForLabour = async (labour) => {
  if (labour.role === 'owner') return labour._id;
  if (!labour.createdBy)
    throw new ApiError(400, 'Labour account has no owner assigned');
  return labour.createdBy;
};

const ensureDraftReport = async (report) => {
  if (!report) throw new ApiError(404, 'Daily report not found');
  if (report.status === 'submitted') {
    throw new ApiError(400, 'Report already submitted and cannot be modified');
  }
  return report;
};

const verifyLabourAccess = (report, labourId) => {
  console.log('========== VERIFY ==========');
  console.log('Report Labour:', report.labourId);
  console.log('Logged User :', labourId);

  const reportLabourId =
    report.labourId?._id?.toString() ?? report.labourId?.toString();

  console.log('Report LabourId:', reportLabourId);
  console.log('Logged LabourId:', labourId.toString());

  if (reportLabourId !== labourId.toString()) {
    throw new ApiError(403, 'Access denied to this report');
  }
};

const updateQuantityEntry = (entries, customerId, delta) => {
  const list = [...entries];
  const idx = list.findIndex((e) => e.customerId.toString() === customerId);
  if (idx >= 0) {
    const newQty = list[idx].quantity + delta;
    if (newQty <= 0) {
      list.splice(idx, 1);
    } else {
      list[idx] = { ...list[idx], quantity: newQty };
    }
  } else if (delta > 0) {
    list.push({ customerId, quantity: delta });
  }
  return list;
};

const computeTotals = (report) => {
  const totalDelivered = report.deliveries.filter(
    (d) => d.status === 'delivered'
  ).length;
  const totalUndelivered = report.deliveries.filter(
    (d) => d.status === 'undelivered'
  ).length;
  const totalEmptyIn = report.emptyIn.reduce((s, e) => s + e.quantity, 0);
  const totalExtra = report.extra.reduce((s, e) => s + e.quantity, 0);
  const totalNotReceived = report.notReceived.reduce(
    (s, e) => s + e.quantity,
    0
  );
  const totalCollectedAmount = report.payments.reduce(
    (s, p) => s + p.amount,
    0
  );
  return {
    totalDelivered,
    totalUndelivered,
    totalEmptyIn,
    totalExtra,
    totalNotReceived,
    totalCollectedAmount,
  };
};

const dailyReportService = {
  getOrCreateToday: async (labour) => {
    const date = getTodayDate();
    const ownerId = await getOwnerIdForLabour(labour);

    let report = await dailyReportRepository.findByLabourAndDate(
      labour._id,
      date
    );
    if (!report) {
      report = await dailyReportRepository.create({
        labourId: labour._id,
        ownerId,
        date,
        status: 'draft',
        filledOut: 0,
        deliveries: [],
        emptyIn: [],
        extra: [],
        notReceived: [],
        payments: [],
      });
    }
    return dailyReportRepository.findById(report._id);
  },

  setFilledOut: async (labour, reportId, filledOut) => {
    const report = await dailyReportRepository.findById(reportId);
    await ensureDraftReport(report);
    verifyLabourAccess(report, labour._id);
    await dailyReportRepository.update(reportId, { filledOut });
    return dailyReportRepository.findById(reportId);
  },

  markDelivery: async (labour, reportId, { customerId, status, reason }) => {
    const report = await dailyReportRepository.findById(reportId);
    await ensureDraftReport(report);
    verifyLabourAccess(report, labour._id);

    if (status === 'undelivered' && !reason) {
      throw new ApiError(400, 'Reason is required for undelivered status');
    }

    const customer = await customerRepository.findById(customerId);
    if (
      !customer ||
      customer.ownerId.toString() !== report.ownerId.toString()
    ) {
      throw new ApiError(404, 'Customer not found');
    }

    const deliveries = [...report.deliveries];
    const idx = deliveries.findIndex((d) => {
      const id = d.customerId?._id
        ? d.customerId._id.toString()
        : d.customerId.toString();

      return id === customerId.toString();
    });
    console.log('CustomerId:', customerId);
    console.log('Index:', idx);
    console.log(
      deliveries.map((d) => ({
        id: d.customerId?._id
          ? d.customerId._id.toString()
          : d.customerId.toString(),
        status: d.status,
      }))
    );
    const entry = {
      customerId,
      status,
      reason: status === 'undelivered' ? reason : undefined,
    };

    if (idx >= 0) {
      deliveries[idx] = entry;
    } else {
      deliveries.push(entry);
    }

    await dailyReportRepository.update(reportId, { deliveries });
    return dailyReportRepository.findById(reportId);
  },

  updateQuantity: async (labour, reportId, field, customerId, delta) => {
    const report = await dailyReportRepository.findById(reportId);
    await ensureDraftReport(report);
    verifyLabourAccess(report, labour._id);

    const customer = await customerRepository.findById(customerId);
    if (
      !customer ||
      customer.ownerId.toString() !== report.ownerId.toString()
    ) {
      throw new ApiError(404, 'Customer not found');
    }

    const updated = updateQuantityEntry(report[field], customerId, delta);
    await dailyReportRepository.update(reportId, { [field]: updated });
    return dailyReportRepository.findById(reportId);
  },

  addPayment: async (labour, reportId, { customerId, amount, paymentMode }) => {
    const report = await dailyReportRepository.findById(reportId);
    await ensureDraftReport(report);
    verifyLabourAccess(report, labour._id);

    const customer = await customerRepository.findById(customerId);
    if (
      !customer ||
      customer.ownerId.toString() !== report.ownerId.toString()
    ) {
      throw new ApiError(404, 'Customer not found');
    }

    const payments = [...report.payments, { customerId, amount, paymentMode }];
    await dailyReportRepository.update(reportId, { payments });
    return dailyReportRepository.findById(reportId);
  },

  submit: async (labour, reportId) => {
    const report = await dailyReportRepository.findById(reportId);
    await ensureDraftReport(report);
    verifyLabourAccess(report, labour._id);

    if (report.filledOut <= 0) {
      throw new ApiError(400, 'Filled out count must be set before submitting');
    }

    const totals = computeTotals(report);

    await dailyReportRepository.update(reportId, {
      ...totals,
      status: 'submitted',
      submittedAt: new Date(),
    });

    if (report.payments.length > 0) {
      const paymentDocs = report.payments.map((p) => ({
        customerId: p.customerId,
        labourId: labour._id,
        ownerId: report.ownerId,
        dailyReportId: report._id,
        amount: p.amount,
        paymentMode: p.paymentMode,
        date: report.date,
      }));
      await paymentRepository.createMany(paymentDocs);

      for (const p of report.payments) {
        await customerRepository.adjustPendingAmount(p.customerId, -p.amount);
      }
    }

    return dailyReportRepository.findById(reportId);
  },

  getReports: async (ownerId, { date, labourId }) => {
    const filter = { status: 'submitted' };
    if (date) filter.date = date;
    if (labourId) filter.labourId = labourId;
    return dailyReportRepository.findByOwner(ownerId, filter);
  },

  getReportById: async (user, reportId) => {
    const report = await dailyReportRepository.findById(reportId);
    if (!report) throw new ApiError(404, 'Report not found');

    if (
      user.role === 'labour' &&
      report.labourId._id.toString() !== user._id.toString()
    ) {
      throw new ApiError(403, 'Access denied');
    }
    if (
      user.role === 'owner' &&
      report.ownerId.toString() !== user._id.toString()
    ) {
      throw new ApiError(403, 'Access denied');
    }
    return report;
  },
};

module.exports = dailyReportService;
