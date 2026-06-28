const mongoose = require('mongoose');

const deliveryEntrySchema = new mongoose.Schema(
  {
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
    status: { type: String, enum: ['delivered', 'undelivered'], required: true },
    reason: { type: String, trim: true },
  },
  { _id: false }
);

const quantityEntrySchema = new mongoose.Schema(
  {
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
    quantity: { type: Number, required: true, min: 1 },
  },
  { _id: false }
);

const paymentEntrySchema = new mongoose.Schema(
  {
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
    amount: { type: Number, required: true, min: 0 },
    paymentMode: { type: String, enum: ['cash', 'upi', 'bank_transfer'], required: true },
  },
  { _id: false }
);

const dailyReportSchema = new mongoose.Schema(
  {
    labourId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: String, required: true },
    status: { type: String, enum: ['draft', 'submitted'], default: 'draft' },
    filledOut: { type: Number, default: 0, min: 0 },
    deliveries: [deliveryEntrySchema],
    emptyIn: [quantityEntrySchema],
    extra: [quantityEntrySchema],
    notReceived: [quantityEntrySchema],
    payments: [paymentEntrySchema],
    totalDelivered: { type: Number, default: 0 },
    totalUndelivered: { type: Number, default: 0 },
    totalEmptyIn: { type: Number, default: 0 },
    totalExtra: { type: Number, default: 0 },
    totalNotReceived: { type: Number, default: 0 },
    totalCollectedAmount: { type: Number, default: 0 },
    submittedAt: { type: Date },
  },
  { timestamps: true }
);

dailyReportSchema.index({ labourId: 1, date: 1 }, { unique: true });
dailyReportSchema.index({ ownerId: 1, date: 1, status: 1 });

module.exports = mongoose.model('DailyReport', dailyReportSchema);
