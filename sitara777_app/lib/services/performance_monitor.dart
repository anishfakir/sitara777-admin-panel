import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer' as developer;
import 'dart:async';

/// Performance monitoring service to track and log performance metrics
class PerformanceMonitor {
  static bool _isInitialized = false;
  static int _frameCount = 0;
  static int _jankyFrames = 0;
  static double _totalFrameTime = 0;
  static Timer? _reportTimer;
  static List<Duration> _frameTimes = [];
  
  /// Initialize performance monitoring
  static void initialize() {
    if (_isInitialized) return;
    
    try {
      // Track frame performance
      SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
        for (final FrameTiming timing in timings) {
          _trackFrame(timing);
        }
      });
      
      // Start periodic reporting
      _startPeriodicReporting();
      
      _isInitialized = true;
      developer.log('🔍 Performance Monitor initialized');
    } catch (e) {
      developer.log('❌ Performance Monitor initialization failed: $e');
    }
  }
  
  /// Track individual frame performance
  static void _trackFrame(FrameTiming timing) {
    _frameCount++;
    
    final Duration totalTime = timing.totalSpan;
    final Duration buildTime = timing.buildDuration;
    final Duration rasterTime = timing.rasterDuration;
    
    _totalFrameTime += totalTime.inMicroseconds / 1000.0; // Convert to milliseconds
    _frameTimes.add(totalTime);
    
    // Keep only recent frame times (last 100 frames)
    if (_frameTimes.length > 100) {
      _frameTimes.removeAt(0);
    }
    
    // Check for janky frames (> 16.67ms for 60fps)
    if (totalTime.inMilliseconds > 16.67) {
      _jankyFrames++;
      developer.log('⚠️ Janky frame detected: ${totalTime.inMilliseconds}ms (Build: ${buildTime.inMilliseconds}ms, Raster: ${rasterTime.inMilliseconds}ms)');
    }
  }
  
  /// Start periodic performance reporting
  static void _startPeriodicReporting() {
    _reportTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _generatePerformanceReport();
    });
  }
  
  /// Generate and log performance report
  static void _generatePerformanceReport() {
    if (_frameCount == 0) return;
    
    final double avgFrameTime = _totalFrameTime / _frameCount;
    final double jankPercentage = (_jankyFrames / _frameCount) * 100;
    final double fps = 1000 / avgFrameTime;
    
    developer.log('📊 Performance Report:');
    developer.log('   Total Frames: $_frameCount');
    developer.log('   Janky Frames: $_jankyFrames (${jankPercentage.toStringAsFixed(1)}%)');
    developer.log('   Average Frame Time: ${avgFrameTime.toStringAsFixed(2)}ms');
    developer.log('   Average FPS: ${fps.toStringAsFixed(1)}');
    
    // Calculate frame time percentiles
    if (_frameTimes.isNotEmpty) {
      final List<Duration> sortedTimes = List.from(_frameTimes)..sort();
      final Duration p50 = sortedTimes[(sortedTimes.length * 0.5).floor()];
      final Duration p90 = sortedTimes[(sortedTimes.length * 0.9).floor()];
      final Duration p99 = sortedTimes[(sortedTimes.length * 0.99).floor()];
      
      developer.log('   Frame Time P50: ${p50.inMilliseconds}ms');
      developer.log('   Frame Time P90: ${p90.inMilliseconds}ms');
      developer.log('   Frame Time P99: ${p99.inMilliseconds}ms');
    }
  }
  
  /// Get current performance metrics
  static Map<String, dynamic> getCurrentMetrics() {
    if (_frameCount == 0) return {};
    
    final double avgFrameTime = _totalFrameTime / _frameCount;
    final double jankPercentage = (_jankyFrames / _frameCount) * 100;
    final double fps = 1000 / avgFrameTime;
    
    return {
      'totalFrames': _frameCount,
      'jankyFrames': _jankyFrames,
      'jankPercentage': jankPercentage,
      'averageFrameTime': avgFrameTime,
      'averageFPS': fps,
      'isPerformant': jankPercentage < 5.0 && fps > 55,
    };
  }
  
  /// Reset performance counters
  static void reset() {
    _frameCount = 0;
    _jankyFrames = 0;
    _totalFrameTime = 0;
    _frameTimes.clear();
    developer.log('🔄 Performance counters reset');
  }
  
  /// Log a custom performance marker
  static void logMarker(String name, {Map<String, dynamic>? data}) {
    developer.log('🏷️ Performance Marker: $name${data != null ? ' - $data' : ''}');
  }
  
  /// Start measuring a custom operation
  static Stopwatch startMeasurement(String operationName) {
    final stopwatch = Stopwatch()..start();
    developer.log('⏱️ Started measuring: $operationName');
    return stopwatch;
  }
  
  /// End measuring a custom operation
  static void endMeasurement(String operationName, Stopwatch stopwatch) {
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    developer.log('⏱️ Finished measuring: $operationName - ${duration}ms');
    
    // Flag slow operations
    if (duration > 100) {
      developer.log('⚠️ Slow operation detected: $operationName took ${duration}ms');
    }
  }
  
  /// Dispose of performance monitoring
  static void dispose() {
    _reportTimer?.cancel();
    _reportTimer = null;
    _isInitialized = false;
    developer.log('🛑 Performance Monitor disposed');
  }
}
