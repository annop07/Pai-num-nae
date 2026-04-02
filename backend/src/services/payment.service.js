const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const BOOKING_STATUS_CONFIRMED = 'CONFIRMED';
const STATUS_UNPAID = 'UNPAID';
const STATUS_PROOF_SUBMITTED = 'PROOF_SUBMITTED';
const STATUS_CONFIRMED = 'CONFIRMED';
const STATUS_DISPUTED = 'DISPUTED';
const REVIEW_APPROVED = 'APPROVED';
const REVIEW_REJECTED = 'REJECTED';
const ACTION_PROOF_SUBMITTED = 'PROOF_SUBMITTED';
const ACTION_PROOF_RESUBMITTED = 'PROOF_RESUBMITTED';
const ACTION_PROOF_CONFIRMED = 'PROOF_CONFIRMED';
const ACTION_PROOF_REJECTED = 'PROOF_REJECTED';
const ACTION_DOCUMENT_ISSUED = 'DOCUMENT_ISSUED';
const REQUESTABLE_DOCUMENT_TYPES = ['TAX_INVOICE', 'PAYMENT_VOUCHER'];

const DOCUMENT_PREFIX = {
  RECEIPT: 'RC',
  TAX_INVOICE: 'TI',
  PAYMENT_VOUCHER: 'PV',
};

const detailInclude = {
  booking: {
    include: {
      route: {
        select: {
          id: true,
          routeSummary: true,
          departureTime: true,
          startLocation: true,
          endLocation: true,
          pricePerSeat: true,
        },
      },
    },
  },
  route: {
    select: {
      id: true,
      routeSummary: true,
      departureTime: true,
      startLocation: true,
      endLocation: true,
      pricePerSeat: true,
    },
  },
  passenger: {
    select: {
      id: true,
      username: true,
      email: true,
      firstName: true,
      lastName: true,
      phoneNumber: true,
    },
  },
  driver: {
    select: {
      id: true,
      username: true,
      email: true,
      firstName: true,
      lastName: true,
      phoneNumber: true,
    },
  },
  confirmedBy: {
    select: {
      id: true,
      username: true,
      firstName: true,
      lastName: true,
    },
  },
  latestSubmission: {
    include: {
      submittedBy: {
        select: {
          id: true,
          username: true,
          email: true,
          firstName: true,
          lastName: true,
        },
      },
      reviewedBy: {
        select: {
          id: true,
          username: true,
          firstName: true,
          lastName: true,
        },
      },
      evidenceFiles: true,
    },
  },
  proofSubmissions: {
    orderBy: { submissionNo: 'desc' },
    include: {
      submittedBy: {
        select: {
          id: true,
          username: true,
          email: true,
          firstName: true,
          lastName: true,
        },
      },
      reviewedBy: {
        select: {
          id: true,
          username: true,
          firstName: true,
          lastName: true,
        },
      },
      evidenceFiles: true,
    },
  },
  documents: {
    orderBy: { createdAt: 'desc' },
  },
  auditLogs: {
    orderBy: { createdAt: 'desc' },
    include: {
      actionBy: {
        select: {
          id: true,
          username: true,
          firstName: true,
          lastName: true,
        },
      },
    },
  },
};

const historyInclude = {
  route: {
    select: {
      id: true,
      routeSummary: true,
      departureTime: true,
      startLocation: true,
      endLocation: true,
    },
  },
  passenger: {
    select: {
      id: true,
      username: true,
      firstName: true,
      lastName: true,
    },
  },
  driver: {
    select: {
      id: true,
      username: true,
      firstName: true,
      lastName: true,
    },
  },
  latestSubmission: {
    include: {
      evidenceFiles: true,
    },
  },
  documents: {
    orderBy: { createdAt: 'desc' },
  },
};

const bookingPaymentInclude = {
  route: {
    select: {
      id: true,
      driverId: true,
      pricePerSeat: true,
      routeSummary: true,
      departureTime: true,
      startLocation: true,
      endLocation: true,
    },
  },
  passenger: {
    select: {
      id: true,
      username: true,
      email: true,
      firstName: true,
      lastName: true,
      phoneNumber: true,
    },
  },
};

const formatYearMonth = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  return `${year}${month}`;
};

const normalizeRequestedDocumentTypes = (payload = {}) => {
  const merged = [
    ...(Array.isArray(payload.requestedDocumentTypes) ? payload.requestedDocumentTypes : []),
    ...(payload.requestedDocumentType ? [payload.requestedDocumentType] : []),
  ];

  return Array.from(
    new Set(
      merged.filter((type) => REQUESTABLE_DOCUMENT_TYPES.includes(type))
    )
  );
};

const fullName = (user) => {
  const name = [user?.firstName, user?.lastName].filter(Boolean).join(' ').trim();
  return name || user?.username || user?.email || 'Unknown';
};

const isTruthyEnv = (value) => ['1', 'true', 'yes', 'on'].includes(String(value || '').toLowerCase());

const isMockDriverTaxProfileEnabled = () => isTruthyEnv(process.env.PAYMENT_USE_MOCK_DRIVER_TAX_PROFILE);
const isMockReferenceNoEnabled = () => isTruthyEnv(process.env.PAYMENT_USE_MOCK_REFERENCE_NO);

const envStringOrNull = (value) => {
  if (value === undefined || value === null) return null;
  const normalized = String(value).trim();
  return normalized || null;
};

const hashString = (value) => {
  const input = String(value || '');
  let hash = 0;
  for (let index = 0; index < input.length; index += 1) {
    hash = ((hash << 5) - hash + input.charCodeAt(index)) | 0;
  }
  return Math.abs(hash);
};

const buildSeedDigits = (seed, length) => {
  const digits = [];
  let state = hashString(seed) || 1;

  for (let index = 0; index < length; index += 1) {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    digits.push(String(state % 10));
  }

  return digits.join('');
};

const buildThaiTaxIdFromSeed = (seed) => {
  const twelveDigits = buildSeedDigits(`${seed}:tax-id`, 12).split('').map((digit) => Number(digit));
  if (twelveDigits.every((digit) => digit === 0)) {
    twelveDigits[0] = 1;
  }

  const weightedSum = twelveDigits.reduce((sum, digit, index) => sum + (digit * (13 - index)), 0);
  const checkDigit = (11 - (weightedSum % 11)) % 10;

  return `${twelveDigits.join('')}${checkDigit}`;
};

const formatThaiPhoneNumber = (rawPhone, seed) => {
  let digits = String(rawPhone || '').replace(/\D/g, '');

  if (digits.length < 9) {
    digits = `09${buildSeedDigits(`${seed}:phone`, 8)}`;
  } else if (digits.length === 9) {
    digits = `0${digits}`;
  } else if (digits.length > 10) {
    digits = digits.slice(-10);
  }

  if (!digits.startsWith('0')) {
    digits = `0${digits.slice(-9)}`;
  }

  return `${digits.slice(0, 3)}-${digits.slice(3, 6)}-${digits.slice(6, 10)}`;
};

const mockTaxAddresses = [
  '99/9 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
  '88/12 Mittraphap Rd, Mueang Khon Kaen, Khon Kaen 40000',
  '120/5 Phahonyothin Rd, Mueang Chiang Rai, Chiang Rai 57000',
  '45/7 Superhighway Rd, Mueang Chiang Mai, Chiang Mai 50000',
];

const pickMockTaxAddress = (seed) => {
  const index = hashString(`${seed}:address`) % mockTaxAddresses.length;
  return mockTaxAddresses[index];
};

const formatDateYmd = (dateValue) => {
  const date = dateValue instanceof Date ? dateValue : new Date(dateValue);
  if (Number.isNaN(date.getTime())) return formatYearMonth(new Date()) + '01';

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}${month}${day}`;
};

const buildMockReferenceNo = ({ paymentMethod, paidAt, bookingId, submissionNo }) => {
  if (paymentMethod === 'CASH') return null;

  const prefixByMethod = {
    PROMPTPAY: 'PP',
    BANK_TRANSFER: 'BT',
    CARD: 'CD',
    OTHER: 'OT',
  };

  const prefix = prefixByMethod[paymentMethod] || 'RF';
  const datePart = formatDateYmd(paidAt || new Date());
  const seed = `${bookingId}:${paymentMethod}:${submissionNo}:${datePart}`;
  const runningNo = String((hashString(seed) % 9000) + 1000).padStart(4, '0');

  return `${prefix}-${datePart}-${runningNo}`;
};

const resolveSubmissionReferenceNo = ({ payload, bookingId, submissionNo }) => {
  const providedReferenceNo = envStringOrNull(payload.referenceNo);
  if (providedReferenceNo) return providedReferenceNo;
  if (!isMockReferenceNoEnabled()) return null;

  return buildMockReferenceNo({
    paymentMethod: payload.paymentMethod,
    paidAt: payload.paidAt,
    bookingId,
    submissionNo,
  });
};

const buildMockDriverTaxProfile = (driver) => {
  const configuredTaxpayerType = String(process.env.PAYMENT_MOCK_TAXPAYER_TYPE || 'INDIVIDUAL').toUpperCase();
  const taxpayerType = configuredTaxpayerType === 'COMPANY' ? 'COMPANY' : 'INDIVIDUAL';
  const configuredTaxpayerName = envStringOrNull(process.env.PAYMENT_MOCK_TAXPAYER_NAME);
  const configuredTaxId = envStringOrNull(process.env.PAYMENT_MOCK_TAX_ID);
  const configuredBranchCode = envStringOrNull(process.env.PAYMENT_MOCK_BRANCH_CODE);
  const configuredIsHeadOffice = envStringOrNull(process.env.PAYMENT_MOCK_IS_HEAD_OFFICE);
  const configuredTaxAddress = envStringOrNull(process.env.PAYMENT_MOCK_TAX_ADDRESS);
  const configuredEmail = envStringOrNull(process.env.PAYMENT_MOCK_EMAIL);
  const configuredPhoneNumber = envStringOrNull(process.env.PAYMENT_MOCK_PHONE_NUMBER);
  const seed = String(driver?.id || driver?.email || driver?.username || 'mock-driver');
  const resolvedName = fullName(driver);
  const isHeadOffice = configuredIsHeadOffice === null ? true : isTruthyEnv(configuredIsHeadOffice);
  const defaultCompanyName = resolvedName === 'Unknown'
    ? 'Demo Transport Co., Ltd.'
    : `${resolvedName} Transport Co., Ltd.`;

  return {
    taxpayerType,
    taxpayerName: configuredTaxpayerName || (taxpayerType === 'COMPANY' ? defaultCompanyName : resolvedName),
    taxId: configuredTaxId || buildThaiTaxIdFromSeed(seed),
    branchCode: taxpayerType === 'COMPANY'
      ? (isHeadOffice ? null : (configuredBranchCode || '00001'))
      : null,
    isHeadOffice,
    taxAddress: configuredTaxAddress || pickMockTaxAddress(seed),
    email: configuredEmail || driver?.email || `billing+${seed.slice(-6)}@demo.painamnae.app`,
    phoneNumber: formatThaiPhoneNumber(configuredPhoneNumber || driver?.phoneNumber, seed),
    isMock: true,
  };
};

const ensureParticipant = (confirmation, userId) => {
  if (!confirmation) throw new ApiError(404, 'Payment confirmation not found');
  if (confirmation.passengerId !== userId && confirmation.driverId !== userId) {
    throw new ApiError(403, 'Forbidden');
  }
};

const ensureDriverOwner = (confirmation, driverId) => {
  if (!confirmation) throw new ApiError(404, 'Payment confirmation not found');
  if (confirmation.driverId !== driverId) {
    throw new ApiError(403, 'Only the route driver can perform this action');
  }
};

const calculateExpectedAmount = (booking) => Number(booking.route.pricePerSeat) * booking.numberOfSeats;

const roundCurrency = (value) => Math.round((Number(value || 0) + Number.EPSILON) * 100) / 100;

const splitVatFromGross = (grossAmount) => {
  const gross = roundCurrency(grossAmount);
  if (gross <= 0) {
    return {
      base: 0,
      vat: 0,
      gross: 0,
    };
  }

  const base = roundCurrency(gross / 1.07);
  const vat = roundCurrency(gross - base);

  return {
    base,
    vat,
    gross,
  };
};

const fetchDetailedConfirmationTx = (tx, id) =>
  tx.paymentConfirmation.findUnique({
    where: { id },
    include: detailInclude,
  });

const buildPayerSnapshot = (confirmation) => {
  const proof = confirmation.latestSubmission;
  if (proof?.isCorporateRequest) {
    return {
      payerName: proof.companyName,
      payerTaxId: proof.companyTaxId || null,
      payerAddress: proof.companyAddress || null,
    };
  }

  return {
    payerName: fullName(confirmation.passenger),
    payerTaxId: null,
    payerAddress: null,
  };
};

const buildPayeeSnapshot = (confirmation, driverTaxProfile) => {
  if (driverTaxProfile) {
    return {
      payeeName: driverTaxProfile.taxpayerName,
      payeeTaxId: driverTaxProfile.taxId,
      payeeBranchCode: driverTaxProfile.branchCode || null,
      payeeAddress: driverTaxProfile.taxAddress,
    };
  }

  return {
    payeeName: fullName(confirmation.driver),
    payeeTaxId: null,
    payeeBranchCode: null,
    payeeAddress: confirmation.driver.phoneNumber || '-',
  };
};

const createNotification = async (tx, userId, title, body, metadata) => {
  return tx.notification.create({
    data: {
      userId,
      type: 'SYSTEM',
      title,
      body,
      metadata,
    },
  });
};

const ensureBookingForProof = async (bookingId, passengerId) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: bookingPaymentInclude,
  });

  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Only the passenger can submit proof');
  if (booking.status !== BOOKING_STATUS_CONFIRMED) {
    throw new ApiError(400, 'Only confirmed bookings can submit payment proof');
  }

  return booking;
};

const nextDocumentNumber = async (tx, documentType, issuedAt) => {
  const prefix = `${DOCUMENT_PREFIX[documentType]}-${formatYearMonth(issuedAt)}-`;
  const lastDocument = await tx.paymentDocument.findFirst({
    where: {
      documentNumber: {
        startsWith: prefix,
      },
    },
    orderBy: {
      documentNumber: 'desc',
    },
  });

  const lastRunning = lastDocument
    ? Number(String(lastDocument.documentNumber).split('-').pop())
    : 0;

  return `${prefix}${String(lastRunning + 1).padStart(4, '0')}`;
};

const getMyTaxProfile = async (driverId) => {
  const profile = await prisma.driverTaxProfile.findUnique({
    where: { driverId },
  });

  if (profile || !isMockDriverTaxProfileEnabled()) {
    return profile;
  }

  const driver = await prisma.user.findUnique({
    where: { id: driverId },
    select: {
      id: true,
      username: true,
      email: true,
      firstName: true,
      lastName: true,
      phoneNumber: true,
    },
  });

  if (!driver) {
    return buildMockDriverTaxProfile(null);
  }

  return buildMockDriverTaxProfile(driver);
};

const upsertMyTaxProfile = async (driverId, payload) => {
  const existing = await prisma.driverTaxProfile.findUnique({
    where: { driverId },
  });

  if (!existing) {
    return prisma.driverTaxProfile.create({
      data: {
        driverId,
        ...payload,
      },
    });
  }

  return prisma.driverTaxProfile.update({
    where: { driverId },
    data: payload,
  });
};

const submitPaymentProof = async ({ bookingId, payload, evidenceFiles, passengerId }) => {
  const hasEvidenceFiles = Array.isArray(evidenceFiles) && evidenceFiles.length > 0;
  const isCashPayment = payload.paymentMethod === 'CASH';
  const hasNote = typeof payload.note === 'string' && payload.note.trim().length > 0;
  const requestedDocumentTypes = normalizeRequestedDocumentTypes(payload);
  const primaryRequestedDocumentType = requestedDocumentTypes[0] || null;

  if (!isCashPayment && !hasEvidenceFiles) {
    throw new ApiError(400, 'At least one payment evidence file is required');
  }

  if (isCashPayment && !hasNote) {
    throw new ApiError(400, 'Note is required for cash payment');
  }

  const booking = await ensureBookingForProof(bookingId, passengerId);

  return prisma.$transaction(async (tx) => {
    let confirmation = await tx.paymentConfirmation.findUnique({
      where: { bookingId },
    });

    if (!confirmation) {
      confirmation = await tx.paymentConfirmation.create({
        data: {
          bookingId,
          routeId: booking.routeId,
          passengerId,
          driverId: booking.route.driverId,
          expectedAmount: calculateExpectedAmount(booking),
          paidAmount: payload.amount,
          receiverRole: 'DRIVER',
          status: STATUS_UNPAID,
        },
      });
    }

    if (confirmation.status === STATUS_CONFIRMED) {
      throw new ApiError(400, 'Payment has already been confirmed');
    }

    const latestSubmission = await tx.paymentProofSubmission.findFirst({
      where: { paymentConfirmationId: confirmation.id },
      orderBy: { submissionNo: 'desc' },
    });

    const submissionNo = (latestSubmission?.submissionNo || 0) + 1;
    const action = submissionNo === 1 ? ACTION_PROOF_SUBMITTED : ACTION_PROOF_RESUBMITTED;
    const previousStatus = confirmation.status;
    const resolvedReferenceNo = resolveSubmissionReferenceNo({
      payload,
      bookingId,
      submissionNo,
    });

    const submissionData = {
      paymentConfirmationId: confirmation.id,
      submittedById: passengerId,
      submissionNo,
      paymentMethod: payload.paymentMethod,
      paidAt: payload.paidAt,
      amount: payload.amount,
      referenceNo: resolvedReferenceNo,
      note: payload.note || null,
      requestedDocumentType: primaryRequestedDocumentType,
      requestedDocumentTypes: requestedDocumentTypes.length > 0 ? requestedDocumentTypes : null,
      isCorporateRequest: payload.isCorporateRequest,
      companyName: payload.companyName || null,
      companyTaxId: payload.companyTaxId || null,
      companyBranchCode: payload.companyBranchCode || null,
      companyAddress: payload.companyAddress || null,
    };

    if (hasEvidenceFiles) {
      submissionData.evidenceFiles = {
        create: evidenceFiles.map((file) => ({
          fileUrl: file.fileUrl,
          mimeType: file.mimeType || null,
          fileName: file.fileName || null,
          fileSizeBytes: file.fileSizeBytes || null,
        })),
      };
    }

    const submission = await tx.paymentProofSubmission.create({
      data: submissionData,
    });

    await tx.paymentConfirmation.update({
      where: { id: confirmation.id },
      data: {
        paidAmount: payload.amount,
        latestSubmissionId: submission.id,
        status: STATUS_PROOF_SUBMITTED,
        disputedAt: null,
        disputeReason: null,
      },
    });

    await tx.paymentAuditLog.create({
      data: {
        paymentConfirmationId: confirmation.id,
        fromStatus: previousStatus,
        toStatus: STATUS_PROOF_SUBMITTED,
        action,
        actionById: passengerId,
        metadata: {
          submissionNo,
          paymentMethod: payload.paymentMethod,
        },
      },
    });

    await createNotification(
      tx,
      booking.route.driverId,
      'Payment proof submitted',
      'A passenger submitted payment proof for review.',
      {
        kind: 'PAYMENT_PROOF_SUBMITTED',
        paymentConfirmationId: confirmation.id,
        bookingId,
      }
    );

    return fetchDetailedConfirmationTx(tx, confirmation.id);
  }, {
    maxWait: 5000,
    timeout: 15000,
  });
};

const getPaymentConfirmationById = async (id, requesterId) => {
  const confirmation = await prisma.paymentConfirmation.findUnique({
    where: { id },
    include: detailInclude,
  });

  ensureParticipant(confirmation, requesterId);
  return confirmation;
};

const listMyPaymentHistory = async ({ userId, userRole, scope, status, page, limit }) => {
  const effectiveScope = scope || (userRole === 'DRIVER' ? 'driver' : 'passenger');
  const where = {
    ...(effectiveScope === 'driver' ? { driverId: userId } : { passengerId: userId }),
    ...(status ? { status } : {}),
  };

  const skip = (page - 1) * limit;

  const [total, data] = await prisma.$transaction([
    prisma.paymentConfirmation.count({ where }),
    prisma.paymentConfirmation.findMany({
      where,
      include: historyInclude,
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
  ]);

  return {
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

const confirmPaymentProof = async (id, driverId, payload = {}) => {
  return prisma.$transaction(async (tx) => {
    const confirmation = await tx.paymentConfirmation.findUnique({
      where: { id },
      include: {
        latestSubmission: true,
        passenger: {
          select: { id: true },
        },
      },
    });

    ensureDriverOwner(confirmation, driverId);

    if (confirmation.status === STATUS_CONFIRMED) {
      return fetchDetailedConfirmationTx(tx, id);
    }

    if (confirmation.status !== STATUS_PROOF_SUBMITTED || !confirmation.latestSubmissionId) {
      throw new ApiError(400, 'Payment proof is not awaiting review');
    }

    const declaredPaymentMethod = confirmation.latestSubmission.paymentMethod;
    const verifiedPaymentMethod = payload.verifiedPaymentMethod;
    const isMethodMismatch = declaredPaymentMethod !== verifiedPaymentMethod;
    const methodMismatchReason = payload.methodMismatchReason || null;

    if (isMethodMismatch && !methodMismatchReason) {
      throw new ApiError(
        400,
        'Method mismatch reason is required when verified payment method differs from declared payment method'
      );
    }

    const confirmedAt = new Date();

    await tx.paymentProofSubmission.update({
      where: { id: confirmation.latestSubmissionId },
      data: {
        reviewStatus: REVIEW_APPROVED,
        reviewedById: driverId,
        reviewedAt: confirmedAt,
        rejectReason: null,
        verifiedPaymentMethod,
        methodMismatchReason: isMethodMismatch ? methodMismatchReason : null,
      },
    });

    await tx.paymentConfirmation.update({
      where: { id },
      data: {
        status: STATUS_CONFIRMED,
        confirmedAt,
        confirmedById: driverId,
        paidAmount: confirmation.latestSubmission.amount,
        disputedAt: null,
        disputeReason: null,
      },
    });

    await tx.paymentAuditLog.create({
      data: {
        paymentConfirmationId: id,
        fromStatus: STATUS_PROOF_SUBMITTED,
        toStatus: STATUS_CONFIRMED,
        action: ACTION_PROOF_CONFIRMED,
        actionById: driverId,
        metadata: {
          declaredPaymentMethod,
          verifiedPaymentMethod,
          isMethodMismatch,
          methodMismatchReason: isMethodMismatch ? methodMismatchReason : null,
        },
      },
    });

    await createNotification(
      tx,
      confirmation.passenger.id,
      'Payment confirmed',
      'Your payment proof was confirmed by the driver.',
      {
        kind: 'PAYMENT_CONFIRMED',
        paymentConfirmationId: id,
      }
    );

    await createNotification(
      tx,
      driverId,
      'Payment confirmed',
      'You confirmed the passenger payment proof successfully.',
      {
        kind: 'PAYMENT_CONFIRMED',
        paymentConfirmationId: id,
      }
    );

    return fetchDetailedConfirmationTx(tx, id);
  }, {
    maxWait: 5000,
    timeout: 15000,
  });
};

const rejectPaymentProof = async (id, driverId, reason) => {
  return prisma.$transaction(async (tx) => {
    const confirmation = await tx.paymentConfirmation.findUnique({
      where: { id },
      include: {
        latestSubmission: true,
        passenger: {
          select: { id: true },
        },
      },
    });

    ensureDriverOwner(confirmation, driverId);

    if (confirmation.status === STATUS_CONFIRMED) {
      throw new ApiError(400, 'Confirmed payment cannot be rejected');
    }

    if (confirmation.status !== STATUS_PROOF_SUBMITTED || !confirmation.latestSubmissionId) {
      throw new ApiError(400, 'Payment proof is not awaiting review');
    }

    const disputedAt = new Date();

    await tx.paymentProofSubmission.update({
      where: { id: confirmation.latestSubmissionId },
      data: {
        reviewStatus: REVIEW_REJECTED,
        reviewedById: driverId,
        reviewedAt: disputedAt,
        rejectReason: reason,
      },
    });

    await tx.paymentConfirmation.update({
      where: { id },
      data: {
        status: STATUS_DISPUTED,
        disputedAt,
        disputeReason: reason,
      },
    });

    await tx.paymentAuditLog.create({
      data: {
        paymentConfirmationId: id,
        fromStatus: STATUS_PROOF_SUBMITTED,
        toStatus: STATUS_DISPUTED,
        action: ACTION_PROOF_REJECTED,
        actionById: driverId,
        note: reason,
      },
    });

    await createNotification(
      tx,
      confirmation.passenger.id,
      'Payment proof rejected',
      'The driver rejected your payment proof. Please review the note and resubmit if needed.',
      {
        kind: 'PAYMENT_REJECTED',
        paymentConfirmationId: id,
        reason,
      }
    );

    await createNotification(
      tx,
      driverId,
      'Payment proof rejected',
      'You rejected the passenger payment proof.',
      {
        kind: 'PAYMENT_REJECTED',
        paymentConfirmationId: id,
      }
    );

    return fetchDetailedConfirmationTx(tx, id);
  }, {
    maxWait: 5000,
    timeout: 15000,
  });
};

const issuePaymentDocument = async (id, driverId, payload) => {
  return prisma.$transaction(async (tx) => {
    const confirmation = await tx.paymentConfirmation.findUnique({
      where: { id },
      include: {
        latestSubmission: true,
        passenger: {
          select: {
            id: true,
            username: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
        driver: {
          select: {
            id: true,
            username: true,
            email: true,
            firstName: true,
            lastName: true,
            phoneNumber: true,
          },
        },
      },
    });

    ensureDriverOwner(confirmation, driverId);

    if (confirmation.status !== STATUS_CONFIRMED) {
      throw new ApiError(400, 'Payment must be confirmed before issuing a document');
    }

    if (!confirmation.latestSubmission) {
      throw new ApiError(400, 'Payment proof is required before issuing a document');
    }

    const existingDocument = await tx.paymentDocument.findFirst({
      where: {
        paymentConfirmationId: id,
        documentType: payload.documentType,
      },
    });

    if (existingDocument) {
      throw new ApiError(409, 'This document type has already been issued for the payment');
    }

    const persistedDriverTaxProfile = await tx.driverTaxProfile.findUnique({
      where: { driverId },
    });

    const driverTaxProfile =
      persistedDriverTaxProfile ||
      (isMockDriverTaxProfileEnabled() ? buildMockDriverTaxProfile(confirmation.driver) : null);

    if (payload.documentType === 'TAX_INVOICE' && !driverTaxProfile) {
      throw new ApiError(400, 'Driver tax profile is required before issuing a tax invoice');
    }

    const resolvedPaymentMethod =
      confirmation.latestSubmission.verifiedPaymentMethod || confirmation.latestSubmission.paymentMethod;
    const existingSubmissionReferenceNo = envStringOrNull(confirmation.latestSubmission.referenceNo);
    const generatedReferenceNo = buildMockReferenceNo({
      paymentMethod: resolvedPaymentMethod,
      paidAt: confirmation.latestSubmission.paidAt,
      bookingId: confirmation.bookingId,
      submissionNo: confirmation.latestSubmission.submissionNo || 1,
    });
    const resolvedReferenceNo = existingSubmissionReferenceNo || (
      isMockReferenceNoEnabled() ? generatedReferenceNo : null
    );

    if (!existingSubmissionReferenceNo && resolvedReferenceNo) {
      await tx.paymentProofSubmission.update({
        where: { id: confirmation.latestSubmission.id },
        data: { referenceNo: resolvedReferenceNo },
      });
      confirmation.latestSubmission.referenceNo = resolvedReferenceNo;
    }

    const issuedAt = new Date();
    const documentNumber = await nextDocumentNumber(tx, payload.documentType, issuedAt);
    const paidAmount = Number(confirmation.paidAmount || confirmation.expectedAmount);

    let subtotal = roundCurrency(paidAmount);
    let taxAmount = 0;
    let totalAmount = roundCurrency(paidAmount);

    if (payload.documentType === 'TAX_INVOICE') {
      const vatSplit = splitVatFromGross(paidAmount);
      subtotal = vatSplit.base;
      taxAmount = vatSplit.vat;
      totalAmount = vatSplit.gross;
    }
    const payerSnapshot = buildPayerSnapshot(confirmation);
    const payeeSnapshot = buildPayeeSnapshot(confirmation, driverTaxProfile);

    const document = await tx.paymentDocument.create({
      data: {
        paymentConfirmationId: id,
        documentType: payload.documentType,
        documentNumber,
        issuedById: driverId,
        issuedToId: confirmation.passengerId,
        issuedAt,
        paidAt: confirmation.latestSubmission.paidAt,
        paymentMethod: resolvedPaymentMethod,
        referenceNo: resolvedReferenceNo,
        subtotal,
        taxAmount,
        totalAmount,
        ...payerSnapshot,
        ...payeeSnapshot,
        templateData: {
          note: payload.note || null,
          sourceSubmissionId: confirmation.latestSubmission.id,
          requestedDocumentType: confirmation.latestSubmission.requestedDocumentType || null,
          requestedDocumentTypes: Array.isArray(confirmation.latestSubmission.requestedDocumentTypes)
            ? confirmation.latestSubmission.requestedDocumentTypes
            : (confirmation.latestSubmission.requestedDocumentType
              ? [confirmation.latestSubmission.requestedDocumentType]
              : []),
          companyRequest: confirmation.latestSubmission.isCorporateRequest,
          driverTaxProfileSource: persistedDriverTaxProfile ? 'PROFILE' : (driverTaxProfile ? 'MOCK' : 'NONE'),
          declaredPaymentMethod: confirmation.latestSubmission.paymentMethod,
          verifiedPaymentMethod:
            confirmation.latestSubmission.verifiedPaymentMethod || confirmation.latestSubmission.paymentMethod,
          methodMismatchReason: confirmation.latestSubmission.methodMismatchReason || null,
        },
      },
    });

    await tx.paymentAuditLog.create({
      data: {
        paymentConfirmationId: id,
        fromStatus: STATUS_CONFIRMED,
        toStatus: STATUS_CONFIRMED,
        action: ACTION_DOCUMENT_ISSUED,
        actionById: driverId,
        note: payload.documentType,
        metadata: {
          documentId: document.id,
          documentNumber: document.documentNumber,
        },
      },
    });

    await createNotification(
      tx,
      confirmation.passengerId,
      'Payment document issued',
      'A payment document is ready for this trip.',
      {
        kind: 'PAYMENT_DOCUMENT_ISSUED',
        paymentConfirmationId: id,
        documentId: document.id,
        documentNumber,
      }
    );

    await createNotification(
      tx,
      driverId,
      'Payment document issued',
      'You issued a payment document successfully.',
      {
        kind: 'PAYMENT_DOCUMENT_ISSUED',
        paymentConfirmationId: id,
        documentId: document.id,
        documentNumber,
      }
    );

    return document;
  });
};

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
