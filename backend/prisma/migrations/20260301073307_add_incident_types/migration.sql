-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "IncidentType" ADD VALUE 'LOST_ITEM';
ALTER TYPE "IncidentType" ADD VALUE 'NO_SHOW_DRIVER';
ALTER TYPE "IncidentType" ADD VALUE 'NO_SHOW_PASSENGER';
ALTER TYPE "IncidentType" ADD VALUE 'LICENSE_PLATE_MISMATCH';
