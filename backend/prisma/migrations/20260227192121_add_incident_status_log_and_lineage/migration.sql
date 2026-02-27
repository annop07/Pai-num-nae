/*
  Warnings:

  - You are about to drop the column `isSuperseded` on the `Incident` table. All the data in the column will be lost.
  - Added the required column `reason` to the `IncidentStatusLog` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "StatusChangeReason" AS ENUM ('EVIDENCE_REVIEWED', 'POLICY_VIOLATION', 'INSUFFICIENT_EVIDENCE', 'FALSE_REPORT', 'MATTER_RESOLVED', 'REQUIRES_ESCALATION', 'REOPENED', 'OTHER');

-- DropIndex
DROP INDEX "Incident_isSuperseded_idx";

-- AlterTable
ALTER TABLE "Incident" DROP COLUMN "isSuperseded",
ADD COLUMN     "isArchived" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "revisionNumber" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "IncidentStatusLog" ADD COLUMN     "reason" "StatusChangeReason" NOT NULL;

-- CreateIndex
CREATE INDEX "Incident_isArchived_idx" ON "Incident"("isArchived");
