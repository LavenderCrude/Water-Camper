const ApiError = require('../utils/ApiError');

const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse({
    body: req.body,
    query: req.query,
    params: req.params,
  });

  if (!result.success) {
    const message = result.error.errors.map((e) => e.message).join(', ');
    return next(new ApiError(400, message));
  }

  req.validated = result.data;
  next();
};

module.exports = validate;
