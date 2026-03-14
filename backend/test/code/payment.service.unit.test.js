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
}));

describe('payment.service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    prisma.$transaction.mockImplementation(async (callback) => callback(prisma));
  });

  afterEach(() => {
    jest.useRealTimers();
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
      taxAmount: 0,
      note: 'Paid in cash',
    });

    expect(prisma.paymentDocument.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentConfirmationId: 'pc-1',
          documentType: 'RECEIPT',
          documentNumber: 'RC-202603-0010',
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
});
