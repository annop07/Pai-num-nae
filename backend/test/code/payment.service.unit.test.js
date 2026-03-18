const paymentService = require('../../src/services/payment.service');
const prisma = require('../../src/utils/prisma');

jest.mock('../../src/utils/prisma', () => ({
  $transaction: jest.fn(),
  booking: {
    findUnique: jest.fn(),
  },
  driverTaxProfile: {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  paymentConfirmation: {
    count: jest.fn(),
    create: jest.fn(),
    findFirst: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
  },
  paymentProofSubmission: {
    create: jest.fn(),
    findFirst: jest.fn(),
    update: jest.fn(),
  },
  paymentDocument: {
    create: jest.fn(),
    findFirst: jest.fn(),
  },
  paymentAuditLog: {
    create: jest.fn(),
  },
  notification: {
    create: jest.fn(),
  },
  user: {
    findUnique: jest.fn(),
  },
}));

describe('payment.service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    prisma.$transaction.mockImplementation(async (callback) => callback(prisma));
  });

  afterEach(() => {
    jest.useRealTimers();
    delete process.env.PAYMENT_USE_MOCK_DRIVER_TAX_PROFILE;
    delete process.env.PAYMENT_USE_MOCK_REFERENCE_NO;
    delete process.env.PAYMENT_MOCK_TAXPAYER_TYPE;
    delete process.env.PAYMENT_MOCK_TAXPAYER_NAME;
    delete process.env.PAYMENT_MOCK_TAX_ID;
    delete process.env.PAYMENT_MOCK_BRANCH_CODE;
    delete process.env.PAYMENT_MOCK_IS_HEAD_OFFICE;
    delete process.env.PAYMENT_MOCK_TAX_ADDRESS;
    delete process.env.PAYMENT_MOCK_EMAIL;
    delete process.env.PAYMENT_MOCK_PHONE_NUMBER;
  });

  it('submits the first payment proof and creates a confirmation record', async () => {
    prisma.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      routeId: 'route-1',
      passengerId: 'passenger-1',
      numberOfSeats: 2,
      status: 'CONFIRMED',
      route: {
        id: 'route-1',
        driverId: 'driver-1',
        pricePerSeat: 50,
      },
      passenger: {
        id: 'passenger-1',
        username: 'passenger',
      },
    });

    prisma.paymentConfirmation.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        id: 'pc-1',
        bookingId: 'booking-1',
        status: 'PROOF_SUBMITTED',
      });

    prisma.paymentConfirmation.create.mockResolvedValue({
      id: 'pc-1',
      bookingId: 'booking-1',
      status: 'UNPAID',
    });

    prisma.paymentProofSubmission.findFirst.mockResolvedValue(null);
    prisma.paymentProofSubmission.create.mockResolvedValue({
      id: 'pps-1',
      paymentConfirmationId: 'pc-1',
      submissionNo: 1,
    });

    const result = await paymentService.submitPaymentProof({
      bookingId: 'booking-1',
      passengerId: 'passenger-1',
      payload: {
        paymentMethod: 'PROMPTPAY',
        paidAt: new Date('2026-03-14T10:00:00Z'),
        amount: 100,
        requestedDocumentTypes: ['TAX_INVOICE', 'PAYMENT_VOUCHER'],
        isCorporateRequest: false,
      },
      evidenceFiles: [
        {
          fileUrl: 'https://example.com/slip.jpg',
          mimeType: 'image/jpeg',
          fileName: 'slip.jpg',
          fileSizeBytes: 1234,
        },
      ],
    });

    expect(prisma.paymentConfirmation.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          bookingId: 'booking-1',
          passengerId: 'passenger-1',
          driverId: 'driver-1',
          expectedAmount: 100,
        }),
      })
    );

    expect(prisma.paymentProofSubmission.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentConfirmationId: 'pc-1',
          submissionNo: 1,
          paymentMethod: 'PROMPTPAY',
          amount: 100,
          requestedDocumentType: 'TAX_INVOICE',
          requestedDocumentTypes: ['TAX_INVOICE', 'PAYMENT_VOUCHER'],
        }),
      })
    );

    expect(prisma.paymentAuditLog.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentConfirmationId: 'pc-1',
          action: 'PROOF_SUBMITTED',
        }),
      })
    );

    expect(result).toEqual(
      expect.objectContaining({
        id: 'pc-1',
      })
    );
  });

  it('auto-generates referenceNo for non-cash proof when mock reference is enabled', async () => {
    process.env.PAYMENT_USE_MOCK_REFERENCE_NO = 'true';

    prisma.booking.findUnique.mockResolvedValue({
      id: 'booking-ref-1',
      routeId: 'route-1',
      passengerId: 'passenger-1',
      numberOfSeats: 1,
      status: 'CONFIRMED',
      route: {
        id: 'route-1',
        driverId: 'driver-1',
        pricePerSeat: 90,
      },
      passenger: {
        id: 'passenger-1',
        username: 'passenger',
      },
    });

    prisma.paymentConfirmation.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        id: 'pc-ref-1',
        bookingId: 'booking-ref-1',
        status: 'PROOF_SUBMITTED',
      });

    prisma.paymentConfirmation.create.mockResolvedValue({
      id: 'pc-ref-1',
      bookingId: 'booking-ref-1',
      status: 'UNPAID',
    });

    prisma.paymentProofSubmission.findFirst.mockResolvedValue(null);
    prisma.paymentProofSubmission.create.mockResolvedValue({
      id: 'pps-ref-1',
      paymentConfirmationId: 'pc-ref-1',
      submissionNo: 1,
    });

    await paymentService.submitPaymentProof({
      bookingId: 'booking-ref-1',
      passengerId: 'passenger-1',
      payload: {
        paymentMethod: 'PROMPTPAY',
        paidAt: new Date('2026-03-18T10:00:00Z'),
        amount: 90,
        isCorporateRequest: false,
      },
      evidenceFiles: [
        {
          fileUrl: 'https://example.com/slip-ref.jpg',
          mimeType: 'image/jpeg',
          fileName: 'slip-ref.jpg',
          fileSizeBytes: 1111,
        },
      ],
    });

    const createArgs = prisma.paymentProofSubmission.create.mock.calls[0][0];
    expect(createArgs.data.referenceNo).toMatch(/^PP-\d{8}-\d{4}$/);
  });

  it('allows CASH proof without evidence file when note is provided', async () => {
    prisma.booking.findUnique.mockResolvedValue({
      id: 'booking-cash-1',
      routeId: 'route-1',
      passengerId: 'passenger-1',
      numberOfSeats: 1,
      status: 'CONFIRMED',
      route: {
        id: 'route-1',
        driverId: 'driver-1',
        pricePerSeat: 100,
      },
      passenger: {
        id: 'passenger-1',
        username: 'passenger',
      },
    });

    prisma.paymentConfirmation.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        id: 'pc-cash-1',
        bookingId: 'booking-cash-1',
        status: 'PROOF_SUBMITTED',
      });

    prisma.paymentConfirmation.create.mockResolvedValue({
      id: 'pc-cash-1',
      bookingId: 'booking-cash-1',
      status: 'UNPAID',
    });

    prisma.paymentProofSubmission.findFirst.mockResolvedValue(null);
    prisma.paymentProofSubmission.create.mockResolvedValue({
      id: 'pps-cash-1',
      paymentConfirmationId: 'pc-cash-1',
      submissionNo: 1,
    });

    const result = await paymentService.submitPaymentProof({
      bookingId: 'booking-cash-1',
      passengerId: 'passenger-1',
      payload: {
        paymentMethod: 'CASH',
        paidAt: new Date('2026-03-15T10:00:00Z'),
        amount: 100,
        note: 'Paid in cash to driver at drop-off',
        isCorporateRequest: false,
      },
      evidenceFiles: [],
    });

    expect(prisma.paymentProofSubmission.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentMethod: 'CASH',
          note: 'Paid in cash to driver at drop-off',
        }),
      })
    );

    const createArgs = prisma.paymentProofSubmission.create.mock.calls[0][0];
    expect(createArgs.data.evidenceFiles).toBeUndefined();

    expect(result).toEqual(
      expect.objectContaining({
        id: 'pc-cash-1',
      })
    );
  });

  it('rejects non-CASH proof when no evidence file is attached', async () => {
    await expect(
      paymentService.submitPaymentProof({
        bookingId: 'booking-1',
        passengerId: 'passenger-1',
        payload: {
          paymentMethod: 'PROMPTPAY',
          paidAt: new Date('2026-03-15T10:00:00Z'),
          amount: 100,
          isCorporateRequest: false,
        },
        evidenceFiles: [],
      })
    ).rejects.toThrow('At least one payment evidence file is required');

    expect(prisma.booking.findUnique).not.toHaveBeenCalled();
  });

  it('rejects CASH proof when note is missing', async () => {
    await expect(
      paymentService.submitPaymentProof({
        bookingId: 'booking-1',
        passengerId: 'passenger-1',
        payload: {
          paymentMethod: 'CASH',
          paidAt: new Date('2026-03-15T10:00:00Z'),
          amount: 100,
          isCorporateRequest: false,
        },
        evidenceFiles: [],
      })
    ).rejects.toThrow('Note is required for cash payment');

    expect(prisma.booking.findUnique).not.toHaveBeenCalled();
  });

  it('confirms proof with driver-verified payment method and mismatch reason', async () => {
    prisma.paymentConfirmation.findUnique
      .mockResolvedValueOnce({
        id: 'pc-1',
        passengerId: 'passenger-1',
        driverId: 'driver-1',
        status: 'PROOF_SUBMITTED',
        latestSubmissionId: 'pps-1',
        latestSubmission: {
          id: 'pps-1',
          paymentMethod: 'PROMPTPAY',
          amount: 100,
        },
        passenger: {
          id: 'passenger-1',
        },
      })
      .mockResolvedValueOnce({
        id: 'pc-1',
        status: 'CONFIRMED',
      });

    const confirmation = await paymentService.confirmPaymentProof('pc-1', 'driver-1', {
      verifiedPaymentMethod: 'CASH',
      methodMismatchReason: 'Passenger selected wrong method',
    });

    expect(prisma.paymentProofSubmission.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'pps-1' },
        data: expect.objectContaining({
          reviewStatus: 'APPROVED',
          verifiedPaymentMethod: 'CASH',
          methodMismatchReason: 'Passenger selected wrong method',
        }),
      })
    );

    expect(prisma.paymentAuditLog.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          action: 'PROOF_CONFIRMED',
          metadata: expect.objectContaining({
            declaredPaymentMethod: 'PROMPTPAY',
            verifiedPaymentMethod: 'CASH',
            isMethodMismatch: true,
            methodMismatchReason: 'Passenger selected wrong method',
          }),
        }),
      })
    );

    expect(confirmation).toEqual(
      expect.objectContaining({
        id: 'pc-1',
      })
    );
  });

  it('rejects confirm when payment method mismatches without reason', async () => {
    prisma.paymentConfirmation.findUnique.mockResolvedValueOnce({
      id: 'pc-1',
      passengerId: 'passenger-1',
      driverId: 'driver-1',
      status: 'PROOF_SUBMITTED',
      latestSubmissionId: 'pps-1',
      latestSubmission: {
        id: 'pps-1',
        paymentMethod: 'PROMPTPAY',
        amount: 100,
      },
      passenger: {
        id: 'passenger-1',
      },
    });

    await expect(
      paymentService.confirmPaymentProof('pc-1', 'driver-1', {
        verifiedPaymentMethod: 'CASH',
      })
    ).rejects.toThrow(
      'Method mismatch reason is required when verified payment method differs from declared payment method'
    );

    expect(prisma.paymentProofSubmission.update).not.toHaveBeenCalled();
  });

  it('issues receipt numbers using the RC-YYYYMM-RUNNING4 format', async () => {
    jest.useFakeTimers().setSystemTime(new Date('2026-03-14T10:00:00Z'));

    prisma.paymentConfirmation.findUnique.mockResolvedValue({
      id: 'pc-1',
      passengerId: 'passenger-1',
      driverId: 'driver-1',
      paidAmount: 100,
      expectedAmount: 100,
      status: 'CONFIRMED',
      latestSubmission: {
        id: 'pps-1',
        paidAt: new Date('2026-03-14T09:30:00Z'),
        paymentMethod: 'PROMPTPAY',
        verifiedPaymentMethod: 'CASH',
        methodMismatchReason: 'Passenger selected wrong method',
        referenceNo: 'REF123',
        isCorporateRequest: false,
      },
      passenger: {
        id: 'passenger-1',
        firstName: 'Sara',
        lastName: 'Passenger',
        username: 'sara',
        email: 'sara@example.com',
      },
      driver: {
        id: 'driver-1',
        firstName: 'Driver',
        lastName: 'Boy',
        username: 'driverboy',
        email: 'driver@example.com',
        phoneNumber: '0812345678',
      },
    });

    prisma.paymentDocument.findFirst
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({ documentNumber: 'RC-202603-0009' });

    prisma.driverTaxProfile.findUnique.mockResolvedValue(null);
    prisma.paymentDocument.create.mockResolvedValue({
      id: 'doc-1',
      documentNumber: 'RC-202603-0010',
    });

    const document = await paymentService.issuePaymentDocument('pc-1', 'driver-1', {
      documentType: 'RECEIPT',
      note: 'Paid in cash',
    });

    expect(prisma.paymentDocument.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentConfirmationId: 'pc-1',
          documentType: 'RECEIPT',
          documentNumber: 'RC-202603-0010',
          paymentMethod: 'CASH',
        }),
      })
    );

    expect(document).toEqual(
      expect.objectContaining({
        id: 'doc-1',
        documentNumber: 'RC-202603-0010',
      })
    );
  });

  it('derives VAT from gross paid amount when issuing TAX_INVOICE', async () => {
    jest.useFakeTimers().setSystemTime(new Date('2026-03-14T10:00:00Z'));

    prisma.paymentConfirmation.findUnique.mockResolvedValue({
      id: 'pc-2',
      passengerId: 'passenger-1',
      driverId: 'driver-1',
      paidAmount: 100,
      expectedAmount: 100,
      status: 'CONFIRMED',
      latestSubmission: {
        id: 'pps-2',
        paidAt: new Date('2026-03-14T09:30:00Z'),
        paymentMethod: 'PROMPTPAY',
        verifiedPaymentMethod: 'PROMPTPAY',
        methodMismatchReason: null,
        referenceNo: 'TX123',
        isCorporateRequest: false,
      },
      passenger: {
        id: 'passenger-1',
        firstName: 'Sara',
        lastName: 'Passenger',
        username: 'sara',
        email: 'sara@example.com',
      },
      driver: {
        id: 'driver-1',
        firstName: 'Driver',
        lastName: 'Boy',
        username: 'driverboy',
        email: 'driver@example.com',
        phoneNumber: '0812345678',
      },
    });

    prisma.paymentDocument.findFirst
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({ documentNumber: 'TI-202603-0009' });

    prisma.driverTaxProfile.findUnique.mockResolvedValue({
      driverId: 'driver-1',
      taxpayerName: 'Driver Boy Co., Ltd.',
      taxId: '1234567890123',
      branchCode: '00000',
      taxAddress: 'Khon Kaen',
    });

    prisma.paymentDocument.create.mockResolvedValue({
      id: 'doc-2',
      documentNumber: 'TI-202603-0010',
    });

    await paymentService.issuePaymentDocument('pc-2', 'driver-1', {
      documentType: 'TAX_INVOICE',
      note: 'Auto VAT from paid amount',
    });

    expect(prisma.paymentDocument.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentConfirmationId: 'pc-2',
          documentType: 'TAX_INVOICE',
          documentNumber: 'TI-202603-0010',
          subtotal: 93.46,
          taxAmount: 6.54,
          totalAmount: 100,
        }),
      })
    );
  });

  it('uses mock driver tax profile for TAX_INVOICE when enabled and profile is missing', async () => {
    process.env.PAYMENT_USE_MOCK_DRIVER_TAX_PROFILE = 'true';

    jest.useFakeTimers().setSystemTime(new Date('2026-03-14T10:00:00Z'));

    prisma.paymentConfirmation.findUnique.mockResolvedValue({
      id: 'pc-3',
      passengerId: 'passenger-1',
      driverId: 'driver-1',
      paidAmount: 100,
      expectedAmount: 100,
      status: 'CONFIRMED',
      latestSubmission: {
        id: 'pps-3',
        paidAt: new Date('2026-03-14T09:30:00Z'),
        paymentMethod: 'PROMPTPAY',
        verifiedPaymentMethod: 'PROMPTPAY',
        methodMismatchReason: null,
        referenceNo: 'TXMOCK',
        isCorporateRequest: false,
      },
      passenger: {
        id: 'passenger-1',
        firstName: 'Sara',
        lastName: 'Passenger',
        username: 'sara',
        email: 'sara@example.com',
      },
      driver: {
        id: 'driver-1',
        firstName: 'Driver',
        lastName: 'Boy',
        username: 'driverboy',
        email: 'driver@example.com',
        phoneNumber: '0812345678',
      },
    });

    prisma.paymentDocument.findFirst
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({ documentNumber: 'TI-202603-0010' });

    prisma.driverTaxProfile.findUnique.mockResolvedValue(null);

    prisma.paymentDocument.create.mockResolvedValue({
      id: 'doc-3',
      documentNumber: 'TI-202603-0011',
    });

    await paymentService.issuePaymentDocument('pc-3', 'driver-1', {
      documentType: 'TAX_INVOICE',
      note: 'Use mock profile',
    });

    expect(prisma.paymentDocument.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          documentType: 'TAX_INVOICE',
          payeeName: 'Driver Boy',
          payeeTaxId: expect.stringMatching(/^\d{13}$/),
          payeeAddress: expect.any(String),
          templateData: expect.objectContaining({
            driverTaxProfileSource: 'MOCK',
          }),
        }),
      })
    );

    const createCall = prisma.paymentDocument.create.mock.calls[0][0];
    expect(createCall.data.payeeTaxId).not.toBe('0000000000000');
    expect(createCall.data.payeeAddress).not.toBe('Mock Address (Dev Only)');
  });

  it('generates and persists referenceNo during issue document when submission has no reference and mock is enabled', async () => {
    process.env.PAYMENT_USE_MOCK_REFERENCE_NO = 'true';
    process.env.PAYMENT_USE_MOCK_DRIVER_TAX_PROFILE = 'true';

    jest.useFakeTimers().setSystemTime(new Date('2026-03-18T10:00:00Z'));

    prisma.paymentConfirmation.findUnique.mockResolvedValue({
      id: 'pc-ref-doc-1',
      bookingId: 'booking-ref-doc-1',
      passengerId: 'passenger-1',
      driverId: 'driver-1',
      paidAmount: 250,
      expectedAmount: 250,
      status: 'CONFIRMED',
      latestSubmission: {
        id: 'pps-ref-doc-1',
        submissionNo: 3,
        paidAt: new Date('2026-03-18T09:45:00Z'),
        paymentMethod: 'PROMPTPAY',
        verifiedPaymentMethod: 'PROMPTPAY',
        referenceNo: null,
        isCorporateRequest: false,
      },
      passenger: {
        id: 'passenger-1',
        username: 'sara',
        email: 'sara@example.com',
      },
      driver: {
        id: 'driver-1',
        username: 'driverboy',
        email: 'driver@example.com',
      },
    });

    prisma.paymentDocument.findFirst
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({ documentNumber: 'PV-202603-0008' });

    prisma.driverTaxProfile.findUnique.mockResolvedValue(null);
    prisma.paymentDocument.create.mockResolvedValue({
      id: 'doc-ref-1',
      documentNumber: 'PV-202603-0009',
    });

    await paymentService.issuePaymentDocument('pc-ref-doc-1', 'driver-1', {
      documentType: 'PAYMENT_VOUCHER',
      note: 'Issue with mocked reference',
    });

    expect(prisma.paymentProofSubmission.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'pps-ref-doc-1' },
        data: expect.objectContaining({
          referenceNo: expect.stringMatching(/^PP-\d{8}-\d{4}$/),
        }),
      })
    );

    const docCreateArgs = prisma.paymentDocument.create.mock.calls[0][0];
    expect(docCreateArgs.data.referenceNo).toMatch(/^PP-\d{8}-\d{4}$/);
  });
});
