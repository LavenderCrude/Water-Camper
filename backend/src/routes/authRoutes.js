const express = require('express');
const authController = require('../controllers/authController');
const authenticate = require('../middleware/auth');
const validate = require('../middleware/validate');
const asyncHandler = require('../utils/asyncHandler');
const { loginSchema } = require('../validators/schemas');

const router = express.Router();
router.post(
  '/register',
  (req, res, next) => {
    console.log('===== REGISTER API HIT =====');
    console.log(req.body);
    next();
  },
  asyncHandler(authController.register)
);
router.post(
  '/login',
  validate(loginSchema),
  asyncHandler(authController.login)
);
router.post('/logout', authenticate, asyncHandler(authController.logout));
router.get('/me', authenticate, asyncHandler(authController.me));

module.exports = router;
