-- CreateEnum
CREATE TYPE "PaymentConfirmationStatus" AS ENUM ('UNPAID', 'PROOF_SUBMITTED', 'CONFIRMED', 'DISPUTED');

-- CreateEnum
CREATE TYPE "OffAppPaymentMethod" AS ENUM ('CASH', 'BANK_TRANSFER', 'PROMPTPAY', 'QR_CODE', 'OTHER');

-- CreateEnum
CREATE TYPE "PaymentReceiverRole" AS ENUM ('DRIVER', 'PASSENGER', 'OTHER');

-- CreateEnum
CREATE TYPE "ProofReviewStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "PaymentDocumentType" AS ENUM ('RECEIPT', 'TAX_INVOICE', 'PAYMENT_VOUCHER');

-- CreateEnum
CREATE TYPE "PaymentDocumentStatus" AS ENUM ('ISSUED', 'VOIDED');

-- CreateEnum
CREATE TYPE "TaxpayerType" AS ENUM ('INDIVIDUAL', 'COMPANY');

-- CreateEnum
CREATE TYPE "PaymentAuditAction" AS ENUM ('PROOF_SUBMITTED', 'PROOF_CONFIRMED', 'PROOF_REJECTED', 'PROOF_RESUBMITTED', 'DOCUMENT_ISSUED', 'STATUS_UPDATED');

-- CreateTable
CREATE TABLE "DriverTaxProfile" (
    "id" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "taxpayerType" "TaxpayerType" NOT NULL DEFAULT 'INDIVIDUAL',
    "taxpayerName" TEXT NOT NULL,
    "taxId" TEXT NOT NULL,
    "branchCode" TEXT,
    "isHeadOffice" BOOLEAN NOT NULL DEFAULT true,
    "taxAddress" TEXT NOT NULL,
    "email" TEXT,
    "phoneNumber" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DriverTaxProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentConfirmation" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "routeId" TEXT NOT NULL,
    "passengerId" TEXT NOT NULL,
    "driverId" TEXT NOT NULL,
    "expectedAmount" DECIMAL(12,2) NOT NULL,
    "paidAmount" DECIMAL(12,2),
    "currency" VARCHAR(3) NOT NULL DEFAULT 'THB',
    "receiverRole" "PaymentReceiverRole" NOT NULL DEFAULT 'DRIVER',
    "status" "PaymentConfirmationStatus" NOT NULL DEFAULT 'UNPAID',
    "latestSubmissionId" TEXT,
    "confirmedAt" TIMESTAMP(3),
    "confirmedById" TEXT,
    "disputedAt" TIMESTAMP(3),
    "disputeReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentConfirmation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentProofSubmission" (
    "id" TEXT NOT NULL,
    "paymentConfirmationId" TEXT NOT NULL,
    "submittedById" TEXT NOT NULL,
    "reviewedById" TEXT,
    "submissionNo" INTEGER NOT NULL,
    "paymentMethod" "OffAppPaymentMethod" NOT NULL,
    "paidAt" TIMESTAMP(3) NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "referenceNo" TEXT,
    "note" TEXT,
    "isCorporateRequest" BOOLEAN NOT NULL DEFAULT false,
    "companyName" TEXT,
    "companyTaxId" TEXT,
    "companyBranchCode" TEXT,
    "companyAddress" TEXT,
    "reviewStatus" "ProofReviewStatus" NOT NULL DEFAULT 'PENDING',
    "rejectReason" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentProofSubmission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentEvidenceFile" (
    "id" TEXT NOT NULL,
    "paymentSubmissionId" TEXT NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "mimeType" TEXT,
    "fileName" TEXT,
    "fileSizeBytes" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PaymentEvidenceFile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentDocument" (
    "id" TEXT NOT NULL,
    "paymentConfirmationId" TEXT NOT NULL,
    "documentType" "PaymentDocumentType" NOT NULL,
    "status" "PaymentDocumentStatus" NOT NULL DEFAULT 'ISSUED',
    "documentNumber" TEXT NOT NULL,
    "issuedById" TEXT NOT NULL,
    "issuedToId" TEXT NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paidAt" TIMESTAMP(3),
    "paymentMethod" "OffAppPaymentMethod" NOT NULL,
    "referenceNo" TEXT,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'THB',
    "subtotal" DECIMAL(12,2) NOT NULL,
    "taxAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "totalAmount" DECIMAL(12,2) NOT NULL,
    "payerName" TEXT NOT NULL,
    "payerTaxId" TEXT,
    "payerAddress" TEXT,
    "payeeName" TEXT NOT NULL,
    "payeeTaxId" TEXT,
    "payeeBranchCode" TEXT,
    "payeeAddress" TEXT NOT NULL,
    "templateData" JSON,
    "pdfUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentDocument_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentAuditLog" (
    "id" TEXT NOT NULL,
    "paymentConfirmationId" TEXT NOT NULL,
    "fromStatus" "PaymentConfirmationStatus",
    "toStatus" "PaymentConfirmationStatus" NOT NULL,
    "action" "PaymentAuditAction" NOT NULL,
    "note" TEXT,
    "metadata" JSON,
    "actionById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PaymentAuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DriverTaxProfile_driverId_key" ON "DriverTaxProfile"("driverId");

-- CreateIndex
CREATE UNIQUE INDEX "DriverTaxProfile_taxId_key" ON "DriverTaxProfile"("taxId");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentConfirmation_bookingId_key" ON "PaymentConfirmation"("bookingId");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentConfirmation_latestSubmissionId_key" ON "PaymentConfirmation"("latestSubmissionId");

-- CreateIndex
CREATE INDEX "PaymentConfirmation_routeId_idx" ON "PaymentConfirmation"("routeId");

-- CreateIndex
CREATE INDEX "PaymentConfirmation_passengerId_idx" ON "PaymentConfirmation"("passengerId");

-- CreateIndex
CREATE INDEX "PaymentConfirmation_driverId_idx" ON "PaymentConfirmation"("driverId");

-- CreateIndex
CREATE INDEX "PaymentConfirmation_status_idx" ON "PaymentConfirmation"("status");

-- CreateIndex
CREATE INDEX "PaymentConfirmation_createdAt_idx" ON "PaymentConfirmation"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentProofSubmission_paymentConfirmationId_submissionNo_key" ON "PaymentProofSubmission"("paymentConfirmationId", "submissionNo");

-- CreateIndex
CREATE INDEX "PaymentProofSubmission_paymentConfirmationId_createdAt_idx" ON "PaymentProofSubmission"("paymentConfirmationId", "createdAt");

-- CreateIndex
CREATE INDEX "PaymentProofSubmission_submittedById_idx" ON "PaymentProofSubmission"("submittedById");

-- CreateIndex
CREATE INDEX "PaymentProofSubmission_reviewStatus_idx" ON "PaymentProofSubmission"("reviewStatus");

-- CreateIndex
CREATE INDEX "PaymentEvidenceFile_paymentSubmissionId_idx" ON "PaymentEvidenceFile"("paymentSubmissionId");

-- CreateIndex
CREATE INDEX "PaymentEvidenceFile_createdAt_idx" ON "PaymentEvidenceFile"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentDocument_documentNumber_key" ON "PaymentDocument"("documentNumber");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentDocument_paymentConfirmationId_documentType_key" ON "PaymentDocument"("paymentConfirmationId", "documentType");

-- CreateIndex
CREATE INDEX "PaymentDocument_documentType_idx" ON "PaymentDocument"("documentType");

-- CreateIndex
CREATE INDEX "PaymentDocument_issuedById_idx" ON "PaymentDocument"("issuedById");

-- CreateIndex
CREATE INDEX "PaymentDocument_issuedToId_idx" ON "PaymentDocument"("issuedToId");

-- CreateIndex
CREATE INDEX "PaymentDocument_createdAt_idx" ON "PaymentDocument"("createdAt");

-- CreateIndex
CREATE INDEX "PaymentAuditLog_paymentConfirmationId_idx" ON "PaymentAuditLog"("paymentConfirmationId");

-- CreateIndex
CREATE INDEX "PaymentAuditLog_actionById_idx" ON "PaymentAuditLog"("actionById");

-- CreateIndex
CREATE INDEX "PaymentAuditLog_createdAt_idx" ON "PaymentAuditLog"("createdAt");

-- AddForeignKey
ALTER TABLE "DriverTaxProfile" ADD CONSTRAINT "DriverTaxProfile_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_passengerId_fkey" FOREIGN KEY ("passengerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_confirmedById_fkey" FOREIGN KEY ("confirmedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentProofSubmission" ADD CONSTRAINT "PaymentProofSubmission_paymentConfirmationId_fkey" FOREIGN KEY ("paymentConfirmationId") REFERENCES "PaymentConfirmation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentProofSubmission" ADD CONSTRAINT "PaymentProofSubmission_submittedById_fkey" FOREIGN KEY ("submittedById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentProofSubmission" ADD CONSTRAINT "PaymentProofSubmission_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentEvidenceFile" ADD CONSTRAINT "PaymentEvidenceFile_paymentSubmissionId_fkey" FOREIGN KEY ("paymentSubmissionId") REFERENCES "PaymentProofSubmission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentDocument" ADD CONSTRAINT "PaymentDocument_paymentConfirmationId_fkey" FOREIGN KEY ("paymentConfirmationId") REFERENCES "PaymentConfirmation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentDocument" ADD CONSTRAINT "PaymentDocument_issuedById_fkey" FOREIGN KEY ("issuedById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentDocument" ADD CONSTRAINT "PaymentDocument_issuedToId_fkey" FOREIGN KEY ("issuedToId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentAuditLog" ADD CONSTRAINT "PaymentAuditLog_paymentConfirmationId_fkey" FOREIGN KEY ("paymentConfirmationId") REFERENCES "PaymentConfirmation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentAuditLog" ADD CONSTRAINT "PaymentAuditLog_actionById_fkey" FOREIGN KEY ("actionById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaymentConfirmation" ADD CONSTRAINT "PaymentConfirmation_latestSubmissionId_fkey" FOREIGN KEY ("latestSubmissionId") REFERENCES "PaymentProofSubmission"("id") ON DELETE SET NULL ON UPDATE CASCADE;
