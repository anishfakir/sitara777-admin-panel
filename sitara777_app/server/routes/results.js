const express = require('express');
const multer = require('multer');
const path = require('path');
const Result = require('../models/Result');
const { auth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/results/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    // Accept images only
    if (!file.originalname.match(/\.(jpg|JPG|jpeg|JPEG|png|PNG|gif|GIF)$/)) {
      req.fileValidationError = 'Only image files are allowed!';
      return cb(new Error('Only image files are allowed!'), false);
    }
    cb(null, true);
  }
});

// @route   GET /api/results
// @desc    Get results by date
// @access  Private
router.get('/', auth, checkPermission('results'), async (req, res) => {
  try {
    const { date, bazaar, page = 1, limit = 50 } = req.query;
    
    const query = {};
    
    if (date) {
      const searchDate = new Date(date);
      const nextDay = new Date(searchDate);
      nextDay.setDate(nextDay.getDate() + 1);
      
      query.date = {
        $gte: searchDate,
        $lt: nextDay
      };
    }
    
    if (bazaar) {
      query.bazaar = bazaar;
    }

    const results = await Result.find(query)
      .populate('declaredBy', 'username')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Result.countDocuments(query);

    res.json({
      success: true,
      data: {
        results,
        totalPages: Math.ceil(total / limit),
        currentPage: parseInt(page),
        total
      }
    });
  } catch (error) {
    console.error('Get results error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/results
// @desc    Add new result
// @access  Private
router.post('/', auth, checkPermission('results'), async (req, res) => {
  try {
    const {
      bazaar,
      date,
      openResult,
      closeResult,
      jodi,
      openPanna,
      closePanna,
      resultTime
    } = req.body;

    // Check if result already exists for this bazaar and date
    const existingResult = await Result.findOne({
      bazaar,
      date: new Date(date || Date.now())
    });

    if (existingResult) {
      return res.status(400).json({ message: 'Result already exists for this bazaar and date' });
    }

    const result = new Result({
      bazaar,
      date: date || Date.now(),
      openResult,
      closeResult,
      jodi,
      openPanna,
      closePanna,
      resultTime: resultTime || '12:00',
      status: 'declared',
      declaredBy: req.admin._id
    });

    await result.save();
    await result.populate('declaredBy', 'username');

    res.status(201).json({
      success: true,
      message: 'Result added successfully',
      data: { result }
    });
  } catch (error) {
    console.error('Add result error:', error);
    if (error.code === 11000) {
      res.status(400).json({ message: 'Result already exists for this bazaar and date' });
    } else {
      res.status(500).json({ message: 'Server error' });
    }
  }
});

// @route   PUT /api/results/:id
// @desc    Update result
// @access  Private
router.put('/:id', auth, checkPermission('results'), async (req, res) => {
  try {
    const {
      openResult,
      closeResult,
      jodi,
      openPanna,
      closePanna,
      status
    } = req.body;

    const result = await Result.findById(req.params.id);
    if (!result) {
      return res.status(404).json({ message: 'Result not found' });
    }

    // Update fields
    if (openResult) result.openResult = openResult;
    if (closeResult) result.closeResult = closeResult;
    if (jodi) result.jodi = jodi;
    if (openPanna) result.openPanna = openPanna;
    if (closePanna) result.closePanna = closePanna;
    if (status) result.status = status;

    result.declaredBy = req.admin._id;
    
    await result.save();
    await result.populate('declaredBy', 'username');

    res.json({
      success: true,
      message: 'Result updated successfully',
      data: { result }
    });
  } catch (error) {
    console.error('Update result error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/results/:id
// @desc    Delete result
// @access  Private
router.delete('/:id', auth, checkPermission('results'), async (req, res) => {
  try {
    const result = await Result.findById(req.params.id);
    if (!result) {
      return res.status(404).json({ message: 'Result not found' });
    }

    await Result.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Result deleted successfully'
    });
  } catch (error) {
    console.error('Delete result error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/results/:id/upload-chart
// @desc    Upload result chart
// @access  Private
router.post('/:id/upload-chart', auth, checkPermission('results'), upload.single('chart'), async (req, res) => {
  try {
    if (req.fileValidationError) {
      return res.status(400).json({ message: req.fileValidationError });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const result = await Result.findById(req.params.id);
    if (!result) {
      return res.status(404).json({ message: 'Result not found' });
    }

    result.chart = {
      imageUrl: `/uploads/results/${req.file.filename}`
    };

    await result.save();

    res.json({
      success: true,
      message: 'Chart uploaded successfully',
      data: { result }
    });
  } catch (error) {
    console.error('Upload chart error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/results/bazaars
// @desc    Get all bazaar types
// @access  Private
router.get('/bazaars', auth, checkPermission('results'), async (req, res) => {
  try {
    const bazaars = [
      'Milan Day',
      'Milan Night',
      'Rajdhani Day',
      'Rajdhani Night',
      'Kalyan Day',
      'Kalyan Night',
      'Sridevi Day',
      'Sridevi Night',
      'Sitara777'
    ];

    res.json({
      success: true,
      data: { bazaars }
    });
  } catch (error) {
    console.error('Get bazaars error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
