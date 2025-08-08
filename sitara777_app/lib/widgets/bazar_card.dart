import 'package:flutter/material.dart';
import '../models/bazar_model.dart';
import '../theme/app_theme.dart';
import 'glassmorphism_card.dart';

class BazarCard extends StatelessWidget {
  final BazarModel bazar;
  final VoidCallback onTap;

  const BazarCard({
    Key? key,
    required this.bazar,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      onTap: onTap,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Icon(
                  _getBazarIcon(bazar.name),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bazar.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bazar.isOpen
                            ? AppTheme.successColor.withOpacity(0.2)
                            : AppTheme.errorColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bazar.isOpen ? 'OPEN' : 'CLOSED',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bazar.isOpen
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open Time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          bazar.openTime,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Close Time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          bazar.closeTime,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (bazar.currentResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Latest Result',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bazar.currentResult!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(bazar.isOpen ? 'Play Now' : 'View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: bazar.isOpen
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBazarIcon(String bazarName) {
    switch (bazarName.toLowerCase()) {
      case 'kalyan':
        return Icons.star;
      case 'kalyan night':
        return Icons.nights_stay;
      case 'milan day':
        return Icons.wb_sunny;
      case 'milan night':
        return Icons.brightness_3;
      case 'rajdhani day':
        return Icons.account_balance;
      case 'rajdhani night':
        return Icons.account_balance_wallet;
      case 'time bazar':
        return Icons.access_time;
      case 'main mumbai':
        return Icons.location_city;
      case 'main ratan':
        return Icons.diamond;
      case 'sridevi':
        return Icons.favorite;
      case 'madhur morning':
        return Icons.wb_twilight;
      case 'madhuri':
        return Icons.auto_awesome;
      case 'supreme day':
        return Icons.emoji_events;
      case 'kuber':
        return Icons.attach_money;
      case 'kuber express':
        return Icons.speed;
      default:
        return Icons.casino;
    }
  }
}
