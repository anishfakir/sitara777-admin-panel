import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitor widget for tracking 120fps
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showFPS;
  final bool showMemory;
  
  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showFPS = true,
    this.showMemory = true,
  });
  
  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  double _fps = 0.0;
  double _memoryUsage = 0.0;
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }
  
  void _startMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameTime).inMilliseconds;
      
      if (elapsed >= 1000) { // Update every second
        setState(() {
          _fps = (_frameCount * 1000) / elapsed;
          _frameCount = 0;
          _lastFrameTime = now;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showFPS || widget.showMemory)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.showFPS)
                    Text(
                      'FPS: ${_fps.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (widget.showMemory)
                    Text(
                      'Memory: ${_memoryUsage.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Performance overlay for development
class PerformanceOverlay extends StatelessWidget {
  final Widget child;
  
  const PerformanceOverlay({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor(
      showFPS: true,
      showMemory: true,
      child: child,
    );
  }
}

/// Performance tips widget
class PerformanceTips extends StatelessWidget {
  const PerformanceTips({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '120fps Performance Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTip('Use RepaintBoundary for complex widgets'),
            _buildTip('Avoid setState() in build() method'),
            _buildTip('Use ListView.builder for long lists'),
            _buildTip('Dispose controllers in dispose()'),
            _buildTip('Use const constructors when possible'),
            _buildTip('Optimize images with cacheWidth/cacheHeight'),
            _buildTip('Use AnimatedContainer for smooth transitions'),
            _buildTip('Avoid heavy computations in build()'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
} 