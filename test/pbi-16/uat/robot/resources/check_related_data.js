const prisma = require('../../../../../backend/src/utils/prisma');

async function main() {
  const email = process.argv[2] || 'TestPassenger_UAT@gmail.com';

  const user = await prisma.user.findFirst({
    where: { email: email }
  });

  if (user) {
    console.log('USER_STILL_EXISTS');
  } else {
    const bookings = await prisma.booking.findMany({
      where: { passenger: { email: email } }
    }).catch(() => []);

    const incidents = await prisma.incident.findMany({
      where: { reporter: { email: email } }
    }).catch(() => []);

    console.log('BOOKINGS_COUNT:' + bookings.length);
    console.log('INCIDENTS_COUNT:' + incidents.length);

    if (bookings.length === 0 && incidents.length === 0) {
      console.log('RELATED_DATA_CLEANED');
    } else {
      console.log('RELATED_DATA_EXISTS');
    }
  }

  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
