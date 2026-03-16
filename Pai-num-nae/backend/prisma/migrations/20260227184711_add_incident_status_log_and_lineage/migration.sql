-- AlterTable
ALTER TABLE "Incident" ADD COLUMN     "isSuperseded" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "parentIncidentId" TEXT;

-- CreateTable
CREATE TABLE "IncidentStatusLog" (
    "id" TEXT NOT NULL,
    "incidentId" TEXT NOT NULL,
    "fromStatus" "IncidentStatus",
    "toStatus" "IncidentStatus" NOT NULL,
    "changedById" TEXT NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "IncidentStatusLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "IncidentStatusLog_incidentId_idx" ON "IncidentStatusLog"("incidentId");

-- CreateIndex
CREATE INDEX "IncidentStatusLog_createdAt_idx" ON "IncidentStatusLog"("createdAt");

-- CreateIndex
CREATE INDEX "IncidentStatusLog_changedById_idx" ON "IncidentStatusLog"("changedById");

-- CreateIndex
CREATE INDEX "Incident_parentIncidentId_idx" ON "Incident"("parentIncidentId");

-- CreateIndex
CREATE INDEX "Incident_isSuperseded_idx" ON "Incident"("isSuperseded");

-- AddForeignKey
ALTER TABLE "Incident" ADD CONSTRAINT "Incident_parentIncidentId_fkey" FOREIGN KEY ("parentIncidentId") REFERENCES "Incident"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IncidentStatusLog" ADD CONSTRAINT "IncidentStatusLog_incidentId_fkey" FOREIGN KEY ("incidentId") REFERENCES "Incident"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IncidentStatusLog" ADD CONSTRAINT "IncidentStatusLog_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
