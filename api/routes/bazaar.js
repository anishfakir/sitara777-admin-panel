const express = require('express');
const Bazaar = require('../models/Bazaar');
const router = express.Router();

// Get all active bazaars
router.get('/', async (req, res) => {
    try {
        const bazaars = await Bazaar.getActiveBazaars();
        
        res.json({
            success: true,
            message: 'Active bazaars retrieved successfully',
            data: {
                bazaars: bazaars,
                count: bazaars.length
            }
        });

    } catch (error) {
        console.error('Get bazaars error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get bazaars open for betting
router.get('/open', async (req, res) => {
    try {
        const openBazaars = await Bazaar.getOpenForBetting();
        
        res.json({
            success: true,
            message: 'Open bazaars retrieved successfully',
            data: {
                bazaars: openBazaars,
                count: openBazaars.length
            }
        });

    } catch (error) {
        console.error('Get open bazaars error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get specific bazaar details
router.get('/:id', async (req, res) => {
    try {
        const bazaar = await Bazaar.findById(req.params.id);
        
        if (!bazaar) {
            return res.status(404).json({
                success: false,
                message: 'Bazaar not found'
            });
        }

        res.json({
            success: true,
            message: 'Bazaar details retrieved successfully',
            data: { bazaar }
        });

    } catch (error) {
        console.error('Get bazaar details error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get bazaar schedule
router.get('/:id/schedule', async (req, res) => {
    try {
        const bazaar = await Bazaar.findById(req.params.id);
        
        if (!bazaar) {
            return res.status(404).json({
                success: false,
                message: 'Bazaar not found'
            });
        }

        const schedule = {
            name: bazaar.name,
            openTime: bazaar.openTime,
            closeTime: bazaar.closeTime,
            resultDeclaredAt: bazaar.resultDeclaredAt,
            weeklySchedule: bazaar.weeklySchedule,
            isCurrentlyOpen: bazaar.isCurrentlyOpen,
            isBettingClosed: bazaar.isBettingClosed,
            status: bazaar.status
        };

        res.json({
            success: true,
            message: 'Bazaar schedule retrieved successfully',
            data: { schedule }
        });

    } catch (error) {
        console.error('Get bazaar schedule error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get multipliers for a bazaar
router.get('/:id/multipliers', async (req, res) => {
    try {
        const bazaar = await Bazaar.findById(req.params.id);
        
        if (!bazaar) {
            return res.status(404).json({
                success: false,
                message: 'Bazaar not found'
            });
        }

        res.json({
            success: true,
            message: 'Bazaar multipliers retrieved successfully',
            data: {
                bazaar: bazaar.name,
                multipliers: bazaar.multipliers,
                gameTypes: bazaar.gameTypes
            }
        });

    } catch (error) {
        console.error('Get bazaar multipliers error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
