import 'package:flutter/material.dart';
import 'sync_status_indicator.dart';

/// Banner widget that displays connection status and allows user interaction
class ConnectionStatusBanner extends StatefulWidget {
  final bool isConnected;
  final bool isLoading;
  final DateTime? lastSyncTime;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool showDismissButton;
  final bool showRetryButton;
  final bool autoHide;
  final Duration autoHideDuration;
  final bool showProgress;
  final Color? backgroundColor;
  final Color? textColor;

  const ConnectionStatusBanner({
    super.key,
    required this.isConnected,
    this.isLoading = false,
    this.lastSyncTime,
    this.customMessage,
    this.onRetry,
    this.onDismiss,
    this.margin,
    this.padding,
    this.showDismissButton = true,
    this.showRetryButton = true,
    this.autoHide = false,
    this.autoHideDuration = const Duration(seconds: 5),
    this.showProgress = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<ConnectionStatusBanner> createState() => _ConnectionStatusBannerState;
}

class _ConnectionStatusBannerState extends State<ConnectionStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Start slide-in animation
    _slideController.forward();
    
    // Auto-hide if enabled and connected
    if (widget.autoHide && widget.isConnected) {
      _scheduleAutoHide();
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle auto-hide logic
    if (widget.autoHide) {
      if (widget.isConnected && !oldWidget.isConnected) {
        _scheduleAutoHide();
      } else if (!widget.isConnected && oldWidget.isConnected) {
        // Show immediately when connection is lost
        if (!_isVisible) {
          _show();
        }
      }
    }
  }

  void _scheduleAutoHide() {
    Future.delayed(widget.autoHideDuration, () {
      if (mounted && widget.isConnected && _isVisible) {
        _hide();
      }
    });
  }

  void _show() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _slideController.forward();
    }
  }

  void _hide() {
    if (_isVisible) {
      _slideController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main content row
                Row(
                  children: [
                    // Status icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: _getStatusColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Status text and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customMessage ?? _getStatusMessage(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.textColor ?? _getTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_getSubMessage().isNotEmpty) ..[
                            const SizedBox(height: 2),
                            Text(
                              _getSubMessage(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: (widget.textColor ?? _getTextColor()).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showRetryButton && widget.onRetry != null && !widget.isConnected)
                          _buildRetryButton(),
                        
                        if (widget.showRetryButton && widget.showDismissButton && 
                            widget.onRetry != null && !widget.isConnected)
                          const SizedBox(width: 8),
                        
                        if (widget.showDismissButton && widget.onDismiss != null)
                          _buildDismissButton(),
                      ],
                    ),
                  ],
                ),
                
                // Progress indicator (if loading)
                if (widget.showProgress && widget.isLoading) ..[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    backgroundColor: _getStatusColor().withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return TextButton.icon(
      onPressed: widget.isLoading ? null : widget.onRetry,
      icon: widget.isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            )
          : Icon(Icons.refresh, size: 16),
      label: Text(widget.isLoading ? 'Connecting...' : 'Retry'),
      style: TextButton.styleFrom(
        foregroundColor: _getStatusColor(),
        backgroundColor: _getStatusColor().withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDismissButton() {
    return IconButton(
      onPressed: _hide,
      icon: const Icon(Icons.close, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
      ),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  IconData _getStatusIcon() {
    if (widget.isLoading) {
      return Icons.sync;
    } else if (widget.isConnected) {
      return Icons.check_circle_outline;
    } else {
      return Icons.cloud_off_outlined;
    }
  }

  Color _getStatusColor() {
    if (widget.isLoading) {
      return Colors.blue;
    } else if (widget.isConnected) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  Color _getBackgroundColor() {
    return _getStatusColor().withOpacity(0.1);
  }

  Color _getTextColor() {
    return _getStatusColor().withOpacity(0.9);
  }

  String _getStatusMessage() {
    if (widget.isLoading) {
      return 'Connecting to server...';
    } else if (widget.isConnected) {
      return 'Connected to live data';
    } else {
      return 'Connection lost';
    }
  }

  String _getSubMessage() {
    if (widget.isLoading) {
      return 'Synchronizing bazaar data';
    } else if (widget.isConnected) {
      if (widget.lastSyncTime != null) {
        return 'Last updated ${_formatLastSyncTime()}';
      }
      return 'Real-time updates active';
    } else {
      return 'Using cached data - some information may be outdated';
    }
  }

  String _formatLastSyncTime() {
    if (widget.lastSyncTime == null) return 'never';
    
    final now = DateTime.now();
    final diff = now.difference(widget.lastSyncTime!);
    
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

/// Minimal connection status banner for subtle notifications
class MinimalConnectionStatusBanner extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final String? message;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MinimalConnectionStatusBanner({
    super.key,
    required this.isConnected,
    this.isLoading = false,
    this.message,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected && !isLoading && message == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CompactSyncStatusIndicator(
              isConnected: isConnected,
              isLoading: isLoading,
              size: 16,
            ),
            const SizedBox(width: 8),
            
            Expanded(
              child: Text(
                message ?? _getDefaultMessage(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isLoading) {
      return Colors.blue;
    } else if (isConnected) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getDefaultMessage() {
    if (isLoading) {
      return 'Syncing...';
    } else if (isConnected) {
      return 'Live data';
    } else {
      return 'Offline mode';
    }
  }
}

/// Toast-style connection status notification
class ConnectionStatusToast {
  static void show(
    BuildContext context, {
    required bool isConnected,
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    
    final statusColor = isConnected ? Colors.green : Colors.orange;
    final statusIcon = isConnected ? Icons.cloud_done : Icons.cloud_off;
    final statusMessage = message ?? 
        (isConnected ? 'Connected to live data' : 'Connection lost');
    
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              statusIcon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: statusColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
