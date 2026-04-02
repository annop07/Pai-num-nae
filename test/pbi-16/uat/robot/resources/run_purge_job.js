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
  const ninetyDaysAgo = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);

  // ลบ user ที่ deletedAt เกิน 90 วัน
  const result = await prisma.user.deleteMany({
    where: {
      deletedAt: {
        lt: ninetyDaysAgo
      }
    }
  });

  console.log('PURGE_COMPLETED');
  console.log('DELETED_COUNT:' + result.count);
  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
