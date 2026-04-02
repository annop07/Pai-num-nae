// ใช้ Prisma Client จาก backend
const { PrismaClient } = require('../../../../../backend/node_modules/@prisma/client');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: "postgresql://postgres.yrlsvqyabxxdsmpyvuyv:Painamnae2026%40@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1"
    }
  }
});

async function main() {
  const email = process.argv[2] || 'TestPassengerDelete@gmail.com';

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
