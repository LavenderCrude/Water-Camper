const express = require('express');
const customerController = require('../controllers/customerController');
const authenticate = require('../middleware/auth');
const { requireRole } = require('../middleware/rbac');
const validate = require('../middleware/validate');
const asyncHandler = require('../utils/asyncHandler');
const {
  createCustomerSchema,
  updateCustomerSchema,
  idParamSchema,
  searchQuerySchema,
} = require('../validators/schemas');

const router = express.Router();

router.use(authenticate);

router.post(
  '/',
  requireRole('owner'),
  validate(createCustomerSchema),
  asyncHandler(customerController.create)
);
router.get(
  '/',
  requireRole('owner'),
  validate(searchQuerySchema),
  asyncHandler(customerController.getAll)
);
router.get('/assigned', requireRole('labour'), asyncHandler(customerController.getForLabour));
router.get(
  '/:id',
  requireRole('owner'),
  validate(idParamSchema),
  asyncHandler(customerController.getById)
);
router.put(
  '/:id',
  requireRole('owner'),
  validate(updateCustomerSchema),
  asyncHandler(customerController.update)
);
router.delete(
  '/:id',
  requireRole('owner'),
  validate(idParamSchema),
  asyncHandler(customerController.delete)
);

module.exports = router;
