const prisma = require('../../../../../backend/src/utils/prisma');

async function main() {
  const email = process.argv[2] || 'TestPassenger_UAT@gmail.com';
  const ninetyDaysAgo = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);

  const user = await prisma.user.updateMany({
    where: { email: email },
    data: { deletedAt: ninetyDaysAgo }
  });

  console.log('UPDATED:' + user.count);
  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
