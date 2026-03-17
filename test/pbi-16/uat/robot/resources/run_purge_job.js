const deleteUsersAfter90Days = require('../../../../../backend/src/jobs/deleteUsers.job');

async function main() {
  await deleteUsersAfter90Days();
  console.log('PURGE_COMPLETED');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
