import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/market_model.dart';

class SattaMarketCard extends StatelessWidget {
  final SattaMarket market;
  final VoidCallback? onPlayTap;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onWhatsAppTap;

  const SattaMarketCard({
    super.key,
    required this.market,
    this.onPlayTap,
    this.onHistoryTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Market Title and Calendar Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Market Title and WhatsApp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Market Name
                      Text(
                        market.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // WhatsApp Row
                      GestureDetector(
                        onTap: onWhatsAppTap,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              market.whatsappNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Calendar Icon
                GestureDetector(
                  onTap: onHistoryTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D71F7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF2D71F7),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Result Numbers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D71F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2D71F7).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.casino,
                    color: const Color(0xFF2D71F7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    market.resultNumbers,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D71F7),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Betting Status
            Text(
              market.bettingStatus,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: market.statusColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Row: Timing Info and Play Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timing Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Open Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF2D71F7),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last Bids Time Open: ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF2D71F7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            market.openTime,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF2D71F7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Close Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            color: Color(0xFF2D71F7),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last Bids Time Close: ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF2D71F7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            market.closeTime,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF2D71F7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Play Button
                GestureDetector(
                  onTap: market.isBettingOpen ? onPlayTap : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: market.isBettingOpen 
                          ? const Color(0xFF2D71F7) 
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: market.isBettingOpen ? [
                        BoxShadow(
                          color: const Color(0xFF2D71F7).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          market.isBettingOpen ? Icons.play_arrow : Icons.lock,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          market.isBettingOpen ? 'PLAY' : 'CLOSED',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
