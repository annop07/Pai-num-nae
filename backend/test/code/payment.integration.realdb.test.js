const prisma = require('../../src/utils/prisma');
const paymentService = require('../../src/services/payment.service');

describe('Payment flow integration (real DB)', () => {
  const createdConfirmationIds = [];

  const findBookingForTest = async ({ requireDriverNoTaxProfile = false } = {}) => {
    const candidates = await prisma.booking.findMany({
      where: {
        status: 'CONFIRMED',
        paymentConfirmation: { is: null },
      },
      include: {
        route: {
          include: {
            driver: {
              select: {
                id: true,
                driverTaxProfile: true,
              },
            },
          },
        },
      },
      take: 30,
      orderBy: { createdAt: 'desc' },
    });

    if (requireDriverNoTaxProfile) {
      return candidates.find((item) => !item.route.driver.driverTaxProfile) || null;
    }

    return candidates[0] || null;
  };

  const cleanupConfirmation = async (confirmationId) => {
    await prisma.$executeRawUnsafe(
      'DELETE FROM "Notification" WHERE (metadata::jsonb ->> \'paymentConfirmationId\') = $1',
      confirmationId
    );
    await prisma.paymentConfirmation.deleteMany({
      where: { id: confirmationId },
    });
  };

  afterEach(async () => {
    while (createdConfirmationIds.length) {
      const id = createdConfirmationIds.pop();
      await cleanupConfirmation(id);
    }
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('submits, confirms, and issues receipt number in RC-YYYYMM-RUNNING4 format', async () => {
    const booking = await findBookingForTest();
    expect(booking).toBeTruthy();

    const proof = await paymentService.submitPaymentProof({
      bookingId: booking.id,
      passengerId: booking.passengerId,
      payload: {
        paymentMethod: 'PROMPTPAY',
        paidAt: new Date(),
        amount: 123.45,
        referenceNo: `INT-${Date.now()}`,
        note: 'integration-test',
        requestedDocumentType: 'TAX_INVOICE',
        isCorporateRequest: false,
      },
      evidenceFiles: [
        {
          fileUrl: `https://example.com/integration-proof-${Date.now()}.jpg`,
          mimeType: 'image/jpeg',
          fileName: 'integration-proof.jpg',
          fileSizeBytes: 1024,
        },
      ],
    });

    createdConfirmationIds.push(proof.id);
    expect(proof.status).toBe('PROOF_SUBMITTED');
    expect(proof.latestSubmission.requestedDocumentType).toBe('TAX_INVOICE');

    const confirmed = await paymentService.confirmPaymentProof(proof.id, booking.route.driverId, {
      verifiedPaymentMethod: 'PROMPTPAY',
    });
    expect(confirmed.status).toBe('CONFIRMED');

    const document = await paymentService.issuePaymentDocument(proof.id, booking.route.driverId, {
      documentType: 'RECEIPT',
      note: 'integration-test',
    });

    expect(document.documentNumber).toMatch(/^RC-\d{6}-\d{4}$/);
  });

  it('rejects proof and moves status to DISPUTED', async () => {
    const booking = await findBookingForTest();
    expect(booking).toBeTruthy();

    const proof = await paymentService.submitPaymentProof({
      bookingId: booking.id,
      passengerId: booking.passengerId,
      payload: {
        paymentMethod: 'BANK_TRANSFER',
        paidAt: new Date(),
        amount: 88.5,
        referenceNo: `REJECT-${Date.now()}`,
        note: 'integration-reject',
        isCorporateRequest: false,
      },
      evidenceFiles: [
        {
          fileUrl: `https://example.com/integration-reject-${Date.now()}.jpg`,
          mimeType: 'image/jpeg',
          fileName: 'integration-reject.jpg',
          fileSizeBytes: 2048,
        },
      ],
    });

    createdConfirmationIds.push(proof.id);

    const rejected = await paymentService.rejectPaymentProof(
      proof.id,
      booking.route.driverId,
      'Invalid transfer reference'
    );

    expect(rejected.status).toBe('DISPUTED');
    expect(rejected.latestSubmission.reviewStatus).toBe('REJECTED');
    expect(rejected.latestSubmission.rejectReason).toBe('Invalid transfer reference');
  });

  it('requires driver tax profile before issuing TAX_INVOICE', async () => {
    const booking = await findBookingForTest({ requireDriverNoTaxProfile: true });
    expect(booking).toBeTruthy();

    const proof = await paymentService.submitPaymentProof({
      bookingId: booking.id,
      passengerId: booking.passengerId,
      payload: {
        paymentMethod: 'PROMPTPAY',
        paidAt: new Date(),
        amount: 155.75,
        referenceNo: `TAX-${Date.now()}`,
        note: 'integration-tax-profile',
        isCorporateRequest: true,
        companyName: 'Integration Co., Ltd.',
        companyTaxId: '1234567890123',
        companyBranchCode: '00000',
        companyAddress: 'Khon Kaen, Thailand',
      },
      evidenceFiles: [
        {
          fileUrl: `https://example.com/integration-tax-${Date.now()}.jpg`,
          mimeType: 'image/jpeg',
          fileName: 'integration-tax.jpg',
          fileSizeBytes: 1024,
        },
      ],
    });

    createdConfirmationIds.push(proof.id);

    await paymentService.confirmPaymentProof(proof.id, booking.route.driverId, {
      verifiedPaymentMethod: 'PROMPTPAY',
    });

    await expect(
      paymentService.issuePaymentDocument(proof.id, booking.route.driverId, {
        documentType: 'TAX_INVOICE',
        note: 'integration-tax-profile',
      })
    ).rejects.toThrow('Driver tax profile is required before issuing a tax invoice');
  });
});
