const asyncHandler = require('express-async-handler');
const paymentService = require('../services/payment.service');
const { uploadToCloudinary } = require('../utils/cloudinary');

const uploadPaymentEvidence = async (files = []) => {
  if (!files.length) return [];

  const uploads = await Promise.all(
    files.map(async (file) => {
      const result = await uploadToCloudinary(
        file.buffer,
        'painamnae/payments',
        file.mimetype,
        file.originalname
      );

      return {
        fileUrl: result.url,
        mimeType: file.mimetype,
        fileName: file.originalname,
        fileSizeBytes: file.size,
      };
    })
  );

  return uploads;
};

const getMyTaxProfile = asyncHandler(async (req, res) => {
  const profile = await paymentService.getMyTaxProfile(req.user.sub);
  res.status(200).json({ success: true, data: profile });
});

const upsertMyTaxProfile = asyncHandler(async (req, res) => {
  const profile = await paymentService.upsertMyTaxProfile(req.user.sub, req.body);
  res.status(200).json({ success: true, data: profile });
});

const submitPaymentProof = asyncHandler(async (req, res) => {
  const evidenceFiles = await uploadPaymentEvidence(req.files || []);

  const confirmation = await paymentService.submitPaymentProof({
    bookingId: req.params.bookingId,
    payload: req.body,
    evidenceFiles,
    passengerId: req.user.sub,
  });

  res.status(201).json({ success: true, data: confirmation });
});

const getPaymentConfirmationById = asyncHandler(async (req, res) => {
  const confirmation = await paymentService.getPaymentConfirmationById(req.params.id, req.user.sub);
  res.status(200).json({ success: true, data: confirmation });
});

const listMyPaymentHistory = asyncHandler(async (req, res) => {
  const result = await paymentService.listMyPaymentHistory({
    userId: req.user.sub,
    userRole: req.user.role,
    ...req.query,
  });
  res.status(200).json({ success: true, ...result });
});

const confirmPaymentProof = asyncHandler(async (req, res) => {
  const confirmation = await paymentService.confirmPaymentProof(req.params.id, req.user.sub);
  res.status(200).json({ success: true, data: confirmation });
});

const rejectPaymentProof = asyncHandler(async (req, res) => {
  const confirmation = await paymentService.rejectPaymentProof(req.params.id, req.user.sub, req.body.reason);
  res.status(200).json({ success: true, data: confirmation });
});

const issuePaymentDocument = asyncHandler(async (req, res) => {
  const document = await paymentService.issuePaymentDocument(req.params.id, req.user.sub, req.body);
  res.status(201).json({ success: true, data: document });
});

module.exports = {
  getMyTaxProfile,
  upsertMyTaxProfile,
  submitPaymentProof,
  getPaymentConfirmationById,
  listMyPaymentHistory,
  confirmPaymentProof,
  rejectPaymentProof,
  issuePaymentDocument,
};
