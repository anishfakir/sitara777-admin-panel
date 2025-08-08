const express = require('express');
const multer = require('multer');
const { db, storage, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  }
});

// Payments page
router.get('/', async (req, res) => {
  try {
    let paymentMethods = [];
    let pendingPayments = [];

    if (!isDemoMode) {
      const [methodsSnapshot, paymentsSnapshot] = await Promise.all([
        db.collection('payment_methods').get(),
        db.collection('pending_payments').get()
      ]);

      paymentMethods = methodsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      pendingPayments = paymentsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

    } else {
      // Demo data
      paymentMethods = [
        { id: '1', type: 'UPI', qrCodeUrl: 'demo-qr-url', isActive: true }
      ];

      pendingPayments = [
        { id: '1', userName: 'John Doe', mobile: '9876543210', amount: 500, screenshotUrl: 'demo-screenshot', status: 'pending' }
      ];
    }

    res.render('payments/index', {
      title: 'Payment Management',
      paymentMethods,
      pendingPayments,
      user: req.session.user
    });

  } catch (error) {
    console.error('Payments error:', error);
    res.render('payments/index', {
      title: 'Payment Management',
      paymentMethods: [],
      pendingPayments: [],
      user: req.session.user,
      error: 'Failed to load payment data'
    });
  }
});

// Upload QR code
router.post('/upload-qr', upload.single('qrCode'), async (req, res) => {
  try {
    if (!req.file) {
      req.flash('error', 'Please select a QR code image');
      return res.redirect('/payments');
    }

    const { paymentType, upiId } = req.body;

    if (!paymentType || !upiId) {
      req.flash('error', 'Payment type and UPI ID are required');
      return res.redirect('/payments');
    }

    let qrCodeUrl = 'demo-qr-url';

    if (!isDemoMode) {
      // Upload to Firebase Storage
      const bucket = storage.bucket();
      const fileName = `qr-codes/${Date.now()}-${req.file.originalname}`;
      const file = bucket.file(fileName);

      await file.save(req.file.buffer, {
        metadata: {
          contentType: req.file.mimetype
        }
      });

      // Get public URL
      const [url] = await file.getSignedUrl({
        action: 'read',
        expires: '03-01-2500'
      });

      qrCodeUrl = url;
    }

    const paymentMethodData = {
      type: paymentType,
      upiId,
      qrCodeUrl,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('payment_methods').add(paymentMethodData);
    }

    req.flash('success', 'QR code uploaded successfully');
    res.redirect('/payments');

  } catch (error) {
    console.error('Upload QR error:', error);
    req.flash('error', 'Failed to upload QR code');
    res.redirect('/payments');
  }
});

// Toggle payment method status
router.post('/toggle-method/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let method = null;

    if (!isDemoMode) {
      const methodDoc = await db.collection('payment_methods').doc(id).get();
      if (methodDoc.exists) {
        method = { id: methodDoc.id, ...methodDoc.data() };
      }
    } else {
      method = { id, isActive: true };
    }

    if (!method) {
      return res.json({ success: false, message: 'Payment method not found' });
    }

    const newStatus = !method.isActive;
    const updateData = {
      isActive: newStatus,
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('payment_methods').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: `Payment method ${newStatus ? 'activated' : 'deactivated'} successfully`,
      isActive: newStatus
    });

  } catch (error) {
    console.error('Toggle payment method error:', error);
    res.json({ success: false, message: 'Failed to toggle payment method' });
  }
});

// Approve payment
router.post('/approve-payment/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let payment = null;

    if (!isDemoMode) {
      const paymentDoc = await db.collection('pending_payments').doc(id).get();
      if (paymentDoc.exists) {
        payment = { id: paymentDoc.id, ...paymentDoc.data() };
      }
    } else {
      payment = { id, amount: 500, userMobile: '9876543210' };
    }

    if (!payment) {
      return res.json({ success: false, message: 'Payment not found' });
    }

    if (payment.status !== 'pending') {
      return res.json({ success: false, message: 'Payment is not pending' });
    }

    const updateData = {
      status: 'approved',
      approvedAt: new Date(),
      approvedBy: req.session.user.username
    };

    if (!isDemoMode) {
      // Update payment status
      await db.collection('pending_payments').doc(id).update(updateData);
      
      // Add to user wallet
      const userDoc = await db.collection('users').doc(payment.userMobile).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        const newWallet = (userData.wallet || 0) + payment.amount;
        await db.collection('users').doc(payment.userMobile).update({
          wallet: newWallet,
          updatedAt: new Date()
        });
      }
    }

    res.json({ 
      success: true, 
      message: 'Payment approved successfully'
    });

  } catch (error) {
    console.error('Approve payment error:', error);
    res.json({ success: false, message: 'Failed to approve payment' });
  }
});

// Reject payment
router.post('/reject-payment/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    let payment = null;
    if (!isDemoMode) {
      const paymentDoc = await db.collection('pending_payments').doc(id).get();
      if (paymentDoc.exists) {
        payment = { id: paymentDoc.id, ...paymentDoc.data() };
      }
    } else {
      payment = { id, status: 'pending' };
    }

    if (!payment) {
      return res.json({ success: false, message: 'Payment not found' });
    }

    if (payment.status !== 'pending') {
      return res.json({ success: false, message: 'Payment is not pending' });
    }

    const updateData = {
      status: 'rejected',
      rejectedAt: new Date(),
      rejectedBy: req.session.user.username,
      rejectionReason: reason || 'No reason provided'
    };

    if (!isDemoMode) {
      await db.collection('pending_payments').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: 'Payment rejected successfully'
    });

  } catch (error) {
    console.error('Reject payment error:', error);
    res.json({ success: false, message: 'Failed to reject payment' });
  }
});

module.exports = router;
