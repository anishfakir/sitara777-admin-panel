const express = require('express');
const GameResult = require('../models/GameResult');
const router = express.Router();

// Get latest game results
router.get('/latest', async (req, res) => {
    try {
        const results = await GameResult.find().sort({ date: -1, time: -1 }).limit(10);
        
        res.json({
            success: true,
            message: 'Latest game results retrieved successfully',
            data: { results }
        });

    } catch (error) {
        console.error('Get latest results error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get game results history
router.get('/history', async (req, res) => {
    try {
        const { bazaar, startDate, endDate, limit = 50, offset = 0 } = req.query;
        
        let query = {};
        if (bazaar) query.bazaar = bazaar;
        if (startDate && endDate) {
            query.date = {
                $gte: new Date(startDate),
                $lte: new Date(endDate)
            };
        }

        const results = await GameResult.find(query)
            .sort({ date: -1, time: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(offset));
        
        const total = await GameResult.countDocuments(query);

        res.json({
            success: true,
            message: 'Game results history retrieved successfully',
            data: {
                results,
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (parseInt(offset) + parseInt(limit)) < total
                }
            }
        });

    } catch (error) {
        console.error('Get results history error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get specific game result details
router.get('/:id', async (req, res) => {
    try {
        const result = await GameResult.findById(req.params.id);
        
        if (!result) {
            return res.status(404).json({
                success: false,
                message: 'Game result not found'
            });
        }

        res.json({
            success: true,
            message: 'Game result details retrieved successfully',
            data: { result }
        });

    } catch (error) {
        console.error('Get result details error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
