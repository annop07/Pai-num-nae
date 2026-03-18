-- AlterTable
ALTER TABLE "PaymentProofSubmission"
ADD COLUMN "verifiedPaymentMethod" "OffAppPaymentMethod",
ADD COLUMN "methodMismatchReason" TEXT;
