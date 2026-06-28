const express = require('express');
const dashboardController = require('../controllers/dashboardController');
const authenticate = require('../middleware/auth');
const { requireRole } = require('../middleware/rbac');
const validate = require('../middleware/validate');
const asyncHandler = require('../utils/asyncHandler');
const { dashboardQuerySchema } = require('../validators/schemas');

const router = express.Router();

router.use(authenticate, requireRole('owner'));

router.get('/summary', validate(dashboardQuerySchema), asyncHandler(dashboardController.getSummary));
router.get(
  '/analytics',
  validate(dashboardQuerySchema),
  asyncHandler(dashboardController.getAnalytics)
);
router.get(
  '/payments',
  validate(dashboardQuerySchema),
  asyncHandler(dashboardController.getPaymentHistory)
);

module.exports = router;
