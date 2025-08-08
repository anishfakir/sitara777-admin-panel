import 'package:flutter/material.dart';

/// Widget that displays the current synchronization status in the app bar
class SyncStatusIndicator extends StatefulWidget {
  final bool isConnected;
  final bool isLoading;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double size;
  final bool showText;

  const SyncStatusIndicator({
    super.key,
    required this.isConnected,
    required this.isLoading,
    this.lastSyncTime,
    this.onTap,
    this.padding,
    this.size = 24.0,
    this.showText = false,
  });

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState;
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _updateAnimation();
  }

  @override
  void didUpdateWidget(SyncStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.isConnected != widget.isConnected) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isConnected) {
      // Slow pulse animation for disconnected state
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(8),
        child: widget.showText ? _buildWithText(context) : _buildIconOnly(context),
      ),
    );
  }

  Widget _buildIconOnly(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Widget iconWidget = Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
          size: widget.size,
        );

        if (widget.isLoading) {
          iconWidget = Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: iconWidget,
          );
        } else if (!widget.isConnected) {
          iconWidget = Transform.scale(
            scale: _pulseAnimation.value,
            child: iconWidget,
          );
        }

        return Tooltip(
          message: _getTooltipText(),
          child: iconWidget,
        );
      },
    );
  }

  Widget _buildWithText(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon with animation
            Transform.scale(
              scale: widget.isLoading || !widget.isConnected 
                  ? _pulseAnimation.value 
                  : 1.0,
              child: Transform.rotate(
                angle: widget.isLoading 
                    ? _rotationAnimation.value * 2 * 3.14159 
                    : 0.0,
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: widget.size,
                ),
              ),
            ),
            const SizedBox(width: 6),
            
            // Status text
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.lastSyncTime != null && widget.isConnected)
                  Text(
                    _formatLastSyncTime(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  IconData _getStatusIcon() {
    if (widget.isLoading) {
      return Icons.sync;
    } else if (widget.isConnected) {
      return Icons.cloud_done;
    } else {
      return Icons.cloud_off;
    }
  }

  Color _getStatusColor() {
    if (widget.isLoading) {
      return Colors.blue;
    } else if (widget.isConnected) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _getStatusText() {
    if (widget.isLoading) {
      return 'Syncing...';
    } else if (widget.isConnected) {
      return 'Live';
    } else {
      return 'Offline';
    }
  }

  String _getTooltipText() {
    if (widget.isLoading) {
      return 'Synchronizing with server...';
    } else if (widget.isConnected) {
      final lastSync = widget.lastSyncTime != null 
          ? 'Last sync: ${_formatLastSyncTime()}'
          : 'Connected to live data';
      return 'Live connection active\n$lastSync';
    } else {
      return 'No connection\nUsing cached data';
    }
  }

  String _formatLastSyncTime() {
    if (widget.lastSyncTime == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(widget.lastSyncTime!);
    
    if (diff.inSeconds < 10) {
      return 'Just now';
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Compact version of sync status indicator for space-constrained areas
class CompactSyncStatusIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final VoidCallback? onTap;
  final double size;

  const CompactSyncStatusIndicator({
    super.key,
    required this.isConnected,
    required this.isLoading,
    this.onTap,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
          size: size,
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (isLoading) {
      return Icons.sync;
    } else if (isConnected) {
      return Icons.circle;
    } else {
      return Icons.circle_outlined;
    }
  }

  Color _getStatusColor() {
    if (isLoading) {
      return Colors.blue;
    } else if (isConnected) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}

/// Banner-style sync status indicator for full-width display
class BannerSyncStatusIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final DateTime? lastSyncTime;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const BannerSyncStatusIndicator({
    super.key,
    required this.isConnected,
    required this.isLoading,
    this.lastSyncTime,
    this.message,
    this.onRetry,
    this.onDismiss,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected && !isLoading && message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message ?? _getStatusText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lastSyncTime != null)
                  Text(
                    'Last sync: ${_formatLastSyncTime()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          if (onRetry != null && !isConnected)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: _getStatusColor(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 16),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (isLoading) {
      return Icons.sync;
    } else if (isConnected) {
      return Icons.check_circle;
    } else {
      return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    if (isLoading) {
      return Colors.blue;
    } else if (isConnected) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color _getBackgroundColor() {
    return _getStatusColor().withOpacity(0.1);
  }

  String _getStatusText() {
    if (isLoading) {
      return 'Synchronizing data...';
    } else if (isConnected) {
      return 'Connected to live data';
    } else {
      return 'Connection lost - using cached data';
    }
  }

  String _formatLastSyncTime() {
    if (lastSyncTime == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(lastSyncTime!);
    
    if (diff.inSeconds < 10) {
      return 'just now';
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds} seconds ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
