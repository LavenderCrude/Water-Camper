const express = require('express');
const dailyReportController = require('../controllers/dailyReportController');
const authenticate = require('../middleware/auth');
const { requireRole } = require('../middleware/rbac');
const validate = require('../middleware/validate');
const asyncHandler = require('../utils/asyncHandler');
const {
  filledOutSchema,
  deliverySchema,
  quantitySchema,
  paymentSchema,
  idParamSchema,
  dashboardQuerySchema,
} = require('../validators/schemas');

const router = express.Router();

router.use(authenticate);

router.get('/today', requireRole('labour'), asyncHandler(dailyReportController.getToday));
router.patch(
  '/:id/filled-out',
  requireRole('labour'),
  validate(filledOutSchema),
  asyncHandler(dailyReportController.setFilledOut)
);
router.post(
  '/:id/deliveries',
  requireRole('labour'),
  validate(deliverySchema),
  asyncHandler(dailyReportController.markDelivery)
);
router.patch(
  '/:id/empty-in',
  requireRole('labour'),
  validate(quantitySchema),
  asyncHandler(dailyReportController.updateEmptyIn)
);
router.patch(
  '/:id/extra',
  requireRole('labour'),
  validate(quantitySchema),
  asyncHandler(dailyReportController.updateExtra)
);
router.patch(
  '/:id/not-received',
  requireRole('labour'),
  validate(quantitySchema),
  asyncHandler(dailyReportController.updateNotReceived)
);
router.post(
  '/:id/payments',
  requireRole('labour'),
  validate(paymentSchema),
  asyncHandler(dailyReportController.addPayment)
);
router.post(
  '/:id/submit',
  requireRole('labour'),
  validate(idParamSchema),
  asyncHandler(dailyReportController.submit)
);
router.get(
  '/',
  requireRole('owner'),
  validate(dashboardQuerySchema),
  asyncHandler(dailyReportController.getReports)
);
router.get('/:id', validate(idParamSchema), asyncHandler(dailyReportController.getById));

module.exports = router;
