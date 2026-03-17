const prisma = require('../../../../../backend/src/utils/prisma');

async function main() {
  const email = process.argv[2] || 'TestPassenger_UAT@gmail.com';

  const user = await prisma.user.findFirst({
    where: { email: email }
  });

  if (user) {
    console.log('USER_EXISTS:' + user.email);
    console.log('DELETED_AT:' + user.deletedAt);
  } else {
    console.log('USER_NOT_FOUND');
  }

  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
