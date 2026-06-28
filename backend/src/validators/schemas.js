const { z } = require('zod');

const loginSchema = z.object({
  body: z.object({
    mobile: z.string().min(10, 'Valid mobile number required'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  }),
});

const createCustomerSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required'),
    phone: z.string().min(10, 'Valid phone required'),
    address: z.string().min(1, 'Address is required'),
    pendingAmount: z.number().min(0).optional(),
    active: z.boolean().optional(),
  }),
});

const updateCustomerSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    name: z.string().min(1).optional(),
    phone: z.string().min(10).optional(),
    address: z.string().min(1).optional(),
    pendingAmount: z.number().min(0).optional(),
    active: z.boolean().optional(),
  }),
});

const createLabourSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required'),
    mobile: z.string().min(10, 'Valid mobile required'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  }),
});

const filledOutSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    filledOut: z.number().int().min(0, 'Filled out count must be 0 or more'),
  }),
});

const deliverySchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    customerId: z.string().min(1),
    status: z.enum(['delivered', 'undelivered']),
    reason: z.string().optional(),
  }),
});

const quantitySchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    customerId: z.string().min(1),
    delta: z.number().int().refine((v) => v === 1 || v === -1, 'Delta must be 1 or -1'),
  }),
});

const paymentSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    customerId: z.string().min(1),
    amount: z.number().min(0),
    paymentMode: z.enum(['cash', 'upi', 'bank_transfer']),
  }),
});

const idParamSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
});

const searchQuerySchema = z.object({
  query: z.object({
    search: z.string().optional(),
    active: z.string().optional(),
  }),
});

const dashboardQuerySchema = z.object({
  query: z.object({
    date: z.string().optional(),
    range: z.enum(['7d', '30d']).optional(),
    labourId: z.string().optional(),
  }),
});

module.exports = {
  loginSchema,
  createCustomerSchema,
  updateCustomerSchema,
  createLabourSchema,
  filledOutSchema,
  deliverySchema,
  quantitySchema,
  paymentSchema,
  idParamSchema,
  searchQuerySchema,
  dashboardQuerySchema,
};
