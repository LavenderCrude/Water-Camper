const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema(
  {
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
    labourId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    dailyReportId: { type: mongoose.Schema.Types.ObjectId, ref: 'DailyReport', required: true },
    amount: { type: Number, required: true, min: 0 },
    paymentMode: { type: String, enum: ['cash', 'upi', 'bank_transfer'], required: true },
    date: { type: String, required: true },
  },
  { timestamps: true }
);

paymentSchema.index({ customerId: 1, date: -1 });
paymentSchema.index({ ownerId: 1, date: -1 });

module.exports = mongoose.model('Payment', paymentSchema);
