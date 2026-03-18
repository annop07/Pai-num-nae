const express = require('express');
const validate = require('../middlewares/validate');
const upload = require('../middlewares/upload.middleware');
const { protect } = require('../middlewares/auth');
const requireDriverVerified = require('../middlewares/driverVerified');
const paymentController = require('../controllers/payment.controller');
const {
  bookingIdParamSchema,
  paymentConfirmationIdParamSchema,
  submitPaymentProofSchema,
  confirmPaymentProofSchema,
  rejectPaymentProofSchema,
  paymentHistoryQuerySchema,
  issuePaymentDocumentSchema,
  upsertDriverTaxProfileSchema,
} = require('../validations/payment.validation');

const router = express.Router();

router.get(
  '/tax-profile/me',
  protect,
  requireDriverVerified,
  paymentController.getMyTaxProfile
);

router.put(
  '/tax-profile/me',
  protect,
  requireDriverVerified,
  validate({ body: upsertDriverTaxProfileSchema }),
  paymentController.upsertMyTaxProfile
);

router.get(
  '/confirmations/history/me',
  protect,
  validate({ query: paymentHistoryQuerySchema }),
  paymentController.listMyPaymentHistory
);

router.get(
  '/confirmations/:id',
  protect,
  validate({ params: paymentConfirmationIdParamSchema }),
  paymentController.getPaymentConfirmationById
);

router.post(
  '/bookings/:bookingId/proof',
  protect,
  upload.array('evidences', 5),
  validate({ params: bookingIdParamSchema, body: submitPaymentProofSchema }),
  paymentController.submitPaymentProof
);

router.post(
  '/confirmations/:id/confirm',
  protect,
  requireDriverVerified,
  validate({ params: paymentConfirmationIdParamSchema, body: confirmPaymentProofSchema }),
  paymentController.confirmPaymentProof
);

router.post(
  '/confirmations/:id/reject',
  protect,
  requireDriverVerified,
  validate({ params: paymentConfirmationIdParamSchema, body: rejectPaymentProofSchema }),
  paymentController.rejectPaymentProof
);

router.post(
  '/confirmations/:id/documents',
  protect,
  requireDriverVerified,
  validate({ params: paymentConfirmationIdParamSchema, body: issuePaymentDocumentSchema }),
  paymentController.issuePaymentDocument
);

module.exports = router;
