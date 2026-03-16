require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function check() {
  const email = 'suphakit.xo@gmail.com';
  console.log(`Checking bookings for ${email}...`);
  
  const user = await prisma.user.findUnique({ where: { email } });
  
  if (!user) {
    console.log(`User ${email} not found.`);
    return;
  }

  const bookings = await prisma.booking.findMany({
    where: { passengerId: user.id },
    include: { route: true }
  });

  console.log(`User ID: ${user.id}`);
  console.log(`Total Bookings: ${bookings.length}`);
  bookings.forEach(b => {
    console.log(`- ID: ${b.id} | Status: ${b.status} | Route: ${b.routeId}`);
  });

  const confirmed = bookings.filter(b => b.status === 'CONFIRMED');
  console.log(`Confirmed Bookings: ${confirmed.length}`);
}

check().catch(e => console.error(e)).finally(() => prisma.$disconnect());
