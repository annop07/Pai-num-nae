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
