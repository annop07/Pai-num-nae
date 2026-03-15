const prisma = require('../utils/prisma');

const deleteUsersAfter90Days = async () => {
  try {

    const now = new Date();

    const ninetyDaysAgo = new Date(
      now.getTime() - 90 * 24 * 60 * 60 * 1000
    );

    const deletedUsers = await prisma.user.deleteMany({
      where: {
        deletedAt: {
          lte: ninetyDaysAgo
        }
      }
    });

    console.log(
      `Deleted ${deletedUsers.count} users scheduled for deletion`
    );

  } catch (error) {
    console.error('Error deleting users:', error);
  }
};

module.exports = deleteUsersAfter90Days;