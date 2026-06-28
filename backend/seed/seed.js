require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Customer = require('../src/models/Customer');
const { mongoUri } = require('../src/config/env');

const seed = async () => {
  await mongoose.connect(mongoUri);
  console.log('Connected to MongoDB for seeding');

  await Promise.all([
    User.deleteMany({}),
    Customer.deleteMany({}),
  ]);

  const owner = await User.create({
    name: 'Water Supplier Owner',
    mobile: '9876543210',
    password: 'owner123',
    role: 'owner',
  });

  const labour = await User.create({
    name: 'Delivery Labour',
    mobile: '9876543211',
    password: 'labour123',
    role: 'labour',
    createdBy: owner._id,
  });

  const customers = [
    { name: 'Rajesh Store', phone: '9123456780', address: 'MG Road, Shop 12', pendingAmount: 500 },
    { name: 'Sunita Hotel', phone: '9123456781', address: 'Station Road', pendingAmount: 1200 },
    { name: 'Green Mart', phone: '9123456782', address: 'Market Area, Block A', pendingAmount: 0 },
    { name: 'City Cafe', phone: '9123456783', address: 'Main Street 45', pendingAmount: 800 },
    { name: 'Fresh Juice Corner', phone: '9123456784', address: 'Park Lane 3', pendingAmount: 300 },
    { name: 'Office Complex A', phone: '9123456785', address: 'IT Park Building 2', pendingAmount: 2000 },
    { name: 'School Canteen', phone: '9123456786', address: 'School Road', pendingAmount: 150 },
    { name: 'Medical Store', phone: '9123456787', address: 'Hospital Lane', pendingAmount: 450 },
  ];

  for (const c of customers) {
    await Customer.create({ ...c, ownerId: owner._id, active: true });
  }

  console.log('\nSeed completed successfully!\n');
  console.log('Owner login: 9876543210 / owner123');
  console.log('Labour login: 9876543211 / labour123');
  console.log(`Created ${customers.length} sample customers\n`);

  await mongoose.disconnect();
};

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
