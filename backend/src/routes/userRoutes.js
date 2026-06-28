const express = require('express');
const userController = require('../controllers/userController');
const authenticate = require('../middleware/auth');
const { requireRole } = require('../middleware/rbac');
const validate = require('../middleware/validate');
const asyncHandler = require('../utils/asyncHandler');
const { createLabourSchema } = require('../validators/schemas');

const router = express.Router();

router.use(authenticate, requireRole('owner'));

router.post('/labour', validate(createLabourSchema), asyncHandler(userController.createLabour));
router.get('/labour', asyncHandler(userController.getLabourAccounts));

module.exports = router;
