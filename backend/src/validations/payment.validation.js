const { z } = require('zod');

const PAYMENT_CONFIRMATION_STATUSES = ['UNPAID', 'PROOF_SUBMITTED', 'CONFIRMED', 'DISPUTED'];
const OFF_APP_PAYMENT_METHODS = ['CASH', 'PROMPTPAY', 'BANK_TRANSFER', 'CARD', 'OTHER'];
const PAYMENT_DOCUMENT_TYPES = ['RECEIPT', 'TAX_INVOICE', 'PAYMENT_VOUCHER'];
const REQUESTABLE_DOCUMENT_TYPES = ['TAX_INVOICE', 'PAYMENT_VOUCHER'];
const TAXPAYER_TYPES = ['INDIVIDUAL', 'COMPANY'];
const HISTORY_SCOPES = ['driver', 'passenger'];

const toNumber = (value) => {
  if (typeof value === 'string' && value.trim() !== '') return Number(value);
  return value;
};

const toBoolean = (value) => {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    if (value.toLowerCase() === 'true') return true;
    if (value.toLowerCase() === 'false') return false;
  }
  return value;
};

const toDate = (value) => {
  if (value instanceof Date) return value;
  if (typeof value === 'string' && value.trim() !== '') {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? value : date;
  }
  return value;
};

const toDocumentTypesArray = (value) => {
  if (value == null) return undefined;
  if (Array.isArray(value)) return value;

  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (!trimmed) return undefined;

    if (trimmed.startsWith('[')) {
      try {
        const parsed = JSON.parse(trimmed);
        if (Array.isArray(parsed)) return parsed;
      } catch (_error) {
        return value;
      }
    }

    if (trimmed.includes(',')) {
      return trimmed.split(',').map((item) => item.trim()).filter(Boolean);
    }

    return [trimmed];
  }

  return value;
};

const optionalTrimmedString = z.preprocess(
  (value) => (typeof value === 'string' ? value.trim() || undefined : value),
  z.string().optional()
);

const cuidIdSchema = z.string().cuid({ message: 'Invalid ID format' });

const taxIdSchema = z.string().regex(/^\d{13}$/, 'Tax ID must be 13 digits');

const bookingIdParamSchema = z.object({
  bookingId: cuidIdSchema,
});

const paymentConfirmationIdParamSchema = z.object({
  id: cuidIdSchema,
});

const requestedDocumentTypesSchema = z.preprocess(
  toDocumentTypesArray,
  z
    .array(z.enum(REQUESTABLE_DOCUMENT_TYPES))
    .min(1, 'At least one requested document type is required')
    .max(2, 'At most 2 requested document types are allowed')
    .refine((types) => new Set(types).size === types.length, 'Requested document types must be unique')
    .optional()
);

const submitPaymentProofSchema = z.object({
  paymentMethod: z.enum(OFF_APP_PAYMENT_METHODS, {
    required_error: 'Payment method is required',
  }),
  paidAt: z.preprocess(
    toDate,
    z.date({ required_error: 'Paid date/time is required', invalid_type_error: 'Invalid paid date/time' })
  ),
  amount: z.preprocess(
    toNumber,
    z.number({ required_error: 'Amount is required', invalid_type_error: 'Amount must be a number' })
      .positive('Amount must be greater than 0')
  ),
  referenceNo: optionalTrimmedString,
  note: optionalTrimmedString,
  requestedDocumentType: z.enum(REQUESTABLE_DOCUMENT_TYPES).optional(),
  requestedDocumentTypes: requestedDocumentTypesSchema,
  isCorporateRequest: z.preprocess(toBoolean, z.boolean().optional().default(false)),
  companyName: optionalTrimmedString,
  companyTaxId: z.preprocess(
    (value) => (typeof value === 'string' && value.trim() === '' ? undefined : value),
    taxIdSchema.optional()
  ),
  companyBranchCode: optionalTrimmedString,
  companyAddress: optionalTrimmedString,
}).superRefine((data, ctx) => {
  if (data.paymentMethod === 'CASH' && !data.note) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['note'],
      message: 'Note is required for cash payment',
    });
  }

  const requestedDocumentTypes = Array.from(
    new Set(
      [
        ...(Array.isArray(data.requestedDocumentTypes) ? data.requestedDocumentTypes : []),
        ...(data.requestedDocumentType ? [data.requestedDocumentType] : []),
      ].filter(Boolean)
    )
  );

  if (requestedDocumentTypes.length > 0 && requestedDocumentTypes.length > 2) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['requestedDocumentTypes'],
      message: 'At most 2 requested document types are allowed',
    });
  }

  if (data.isCorporateRequest) {
    if (!requestedDocumentTypes.includes('TAX_INVOICE')) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['isCorporateRequest'],
        message: 'Corporate request requires TAX_INVOICE in requested documents',
      });
    }
    if (!data.companyName) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['companyName'], message: 'Company name is required' });
    }
    if (!data.companyTaxId) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['companyTaxId'], message: 'Company tax ID is required' });
    }
    if (!data.companyAddress) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['companyAddress'], message: 'Company address is required' });
    }
  }
});

const rejectPaymentProofSchema = z.object({
  reason: z.string().trim().min(3, 'Reject reason is required'),
});

const confirmPaymentProofSchema = z.object({
  verifiedPaymentMethod: z.enum(OFF_APP_PAYMENT_METHODS, {
    required_error: 'Verified payment method is required',
  }),
  methodMismatchReason: z.preprocess(
    (value) => (typeof value === 'string' ? value.trim() || undefined : value),
    z.string().min(3, 'Method mismatch reason must be at least 3 characters').optional()
  ),
});

const paymentHistoryQuerySchema = z.object({
  scope: z.enum(HISTORY_SCOPES).optional(),
  status: z.enum(PAYMENT_CONFIRMATION_STATUSES).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

const issuePaymentDocumentSchema = z.object({
  documentType: z.enum(PAYMENT_DOCUMENT_TYPES, {
    required_error: 'Document type is required',
  }),
  note: optionalTrimmedString,
});

const upsertDriverTaxProfileSchema = z.object({
  taxpayerType: z.enum(TAXPAYER_TYPES, {
    required_error: 'Taxpayer type is required',
  }),
  taxpayerName: z.string().trim().min(1, 'Taxpayer name is required'),
  taxId: taxIdSchema,
  branchCode: optionalTrimmedString,
  isHeadOffice: z.preprocess(toBoolean, z.boolean().optional().default(true)),
  taxAddress: z.string().trim().min(1, 'Tax address is required'),
  email: z.preprocess(
    (value) => (typeof value === 'string' && value.trim() === '' ? undefined : value),
    z.string().email('Invalid email').optional()
  ),
  phoneNumber: optionalTrimmedString,
});

module.exports = {
  bookingIdParamSchema,
  paymentConfirmationIdParamSchema,
  submitPaymentProofSchema,
  confirmPaymentProofSchema,
  rejectPaymentProofSchema,
  paymentHistoryQuerySchema,
  issuePaymentDocumentSchema,
  upsertDriverTaxProfileSchema,
  PAYMENT_DOCUMENT_TYPES,
};
