-- CreateIndex
CREATE INDEX "ChatRoom_incidentId_idx" ON "ChatRoom"("incidentId");

-- CreateIndex
CREATE INDEX "ChatRoom_adminId_idx" ON "ChatRoom"("adminId");

-- CreateIndex
CREATE INDEX "ChatRoom_status_idx" ON "ChatRoom"("status");

-- CreateIndex
CREATE INDEX "Message_createdAt_idx" ON "Message"("createdAt");
