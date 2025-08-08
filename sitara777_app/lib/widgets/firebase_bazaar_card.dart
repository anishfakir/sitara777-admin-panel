import 'package:flutter/material.dart';
import '../models/firebase_bazaar_model.dart';

/// Enhanced card widget for displaying Firebase bazaar information
class FirebaseBazaarCard extends StatelessWidget {
  final FirebaseBazaarModel bazaar;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDetailedInfo;
  final bool compact;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FirebaseBazaarCard({
    super.key,
    required this.bazaar,
    this.onTap,
    this.onLongPress,
    this.showDetailedInfo = true,
    this.compact = false,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding ?? EdgeInsets.all(compact ? 12 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bazaar.displayColor.withOpacity(0.05),
                  bazaar.displayColor.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: bazaar.displayColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: compact ? _buildCompactContent(context) : _buildFullContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bazaar.displayColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: bazaar.displayColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                bazaar.displayIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Bazaar name and short name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bazaar.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (bazaar.shortName.isNotEmpty && bazaar.shortName != bazaar.name)
                    Text(
                      bazaar.shortName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bazaar.statusColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: bazaar.statusColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                bazaar.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Time and result row
        Row(
          children: [
            // Time info
            Expanded(
              flex: 2,
              child: _buildInfoChip(
                context,
                Icons.access_time,
                'Time',
                bazaar.formattedTime,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            
            // Result info
            Expanded(
              flex: 2,
              child: _buildInfoChip(
                context,
                Icons.casino,
                'Result',
                bazaar.hasResult ? bazaar.currentResult : 'Pending',
                bazaar.hasResult ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        
        if (showDetailedInfo) ..[
          const SizedBox(height: 12),
          
          // Tags row
          Row(
            children: [
              // Popular tag
              if (bazaar.isPopular)
                _buildTag(
                  context,
                  Icons.star,
                  'Popular',
                  Colors.amber,
                ),
              
              if (bazaar.isPopular) const SizedBox(width: 8),
              
              // Open status tag
              _buildTag(
                context,
                bazaar.isOpen ? Icons.play_circle : Icons.pause_circle,
                bazaar.isOpen ? 'Open' : 'Closed',
                bazaar.isOpen ? Colors.green : Colors.red,
              ),
              
              const Spacer(),
              
              // Last updated
              Text(
                'Updated ${bazaar.lastUpdatedText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
        
        // Game types (if available)
        if (showDetailedInfo && bazaar.gameTypes.isNotEmpty) ..[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: bazaar.gameTypes.take(3).map((gameType) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bazaar.displayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bazaar.displayColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  gameType,
                  style: TextStyle(
                    color: bazaar.displayColor.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bazaar.displayColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            bazaar.displayIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Name and time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bazaar.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                bazaar.formattedTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Status and result
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bazaar.statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bazaar.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (bazaar.hasResult)
              Text(
                bazaar.currentResult,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
