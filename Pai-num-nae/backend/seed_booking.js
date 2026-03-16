const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seed() {
  const email = 'suphakit.xo@gmail.com';
  console.log(`Seeding booking for ${email}...`);
  
  const user = await prisma.user.findUnique({ where: { email } });
  
  if (!user) {
    console.log(`User ${email} not found.`);
    return;
  }

  // 1. Create a dummy vehicle if needed
  let vehicle = await prisma.vehicle.findFirst();
  if (!vehicle) {
    vehicle = await prisma.vehicle.create({
      data: {
        userId: user.id, // Just assign to this user for simplicity
        vehicleModel: 'Toyota Fortuner',
        licensePlate: 'TEST-9999',
        vehicleType: 'Car',
        color: 'White',
        seatCapacity: 4,
        amenities: ['Air Condition', 'Music'],
        isDefault: true
      }
    });
  }

  // 2. Create a dummy route
  const route = await prisma.route.create({
    data: {
      driverId: user.id, // Self-driving for simplicity or use another user
      vehicleId: vehicle.id,
      startLocation: { name: 'Bangkok', lat: 13.7563, lng: 100.5018 },
      endLocation: { name: 'Chiang Mai', lat: 18.7883, lng: 98.9853 },
      departureTime: new Date(),
      availableSeats: 3,
      pricePerSeat: 500,
      status: 'AVAILABLE',
      routeSummary: 'Test Route',
      distance: '700 km',
      duration: '9 hours',
    }
  });

  // 3. Create a CONFIRMED booking
  const booking = await prisma.booking.create({
    data: {
      routeId: route.id,
      passengerId: user.id,
      numberOfSeats: 1,
      status: 'CONFIRMED',
      pickupLocation: { name: 'Bangkok', lat: 13.7563, lng: 100.5018 },
      dropoffLocation: { name: 'Chiang Mai', lat: 18.7883, lng: 98.9853 },
    }
  });

  console.log(`Created Booking ID: ${booking.id}`);
}

seed().catch(e => console.error(e)).finally(() => prisma.$disconnect());
