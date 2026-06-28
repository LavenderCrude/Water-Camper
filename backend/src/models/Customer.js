const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phone: { type: String, required: true, trim: true },
    address: { type: String, required: true, trim: true },
    pendingAmount: { type: Number, default: 0, min: 0 },
    active: { type: Boolean, default: true },
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

customerSchema.index({ ownerId: 1, phone: 1 }, { unique: true });
customerSchema.index({ ownerId: 1, active: 1, name: 1 });

module.exports = mongoose.model('Customer', customerSchema);
