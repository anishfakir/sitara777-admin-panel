# Performance Testing Guide for Sitara777

## Quick Performance Testing Steps

### 1. Connect Android Device (Recommended)
```bash
# Check connected devices
flutter devices

# Run in profile mode for accurate performance measurement
flutter run --profile -d [device_id]
```

### 2. Using Flutter DevTools
```bash
# In a separate terminal while app is running
dart devtools

# Open browser and connect to your running app
# Go to Performance tab to analyze frame times
```

### 3. Using Android Studio (Alternative)
1. Open Android Studio
2. Go to View > Tool Windows > Flutter Performance
3. Connect to your running Flutter app
4. Monitor frame rendering times

### 4. Performance Monitoring in App
The app now includes `PerformanceMonitor` which will:
- Log performance metrics every 30 seconds
- Track janky frames (> 16.67ms)
- Calculate average FPS
- Report frame time percentiles

### 5. Key Performance Metrics to Watch
- **Frame Time**: Should be < 16.67ms for 60fps
- **Janky Frames**: Should be < 5% of total frames
- **Average FPS**: Should be > 55fps
- **Memory Usage**: Monitor in DevTools

### 6. Quick Performance Commands
```bash
# Build release APK for final testing
flutter build apk --release

# Run performance tests
flutter run --profile --trace-startup

# Analyze startup time
flutter run --profile --dart-define=STARTUP_TRACE=true
```

### 7. Performance Optimization Checklist
- ✅ RepaintBoundary widgets implemented
- ✅ Image caching optimized
- ✅ ListView with builders for large lists
- ✅ Lazy loading implemented
- ✅ Unnecessary rebuilds prevented
- ✅ Performance monitoring enabled

### 8. Common Performance Issues to Check
1. **Heavy build methods** - Use `flutter inspector` to identify
2. **Expensive operations in build()** - Move to initState() or separate methods
3. **Large images without optimization** - Use our OptimizedImage widgets
4. **Unnecessary setState() calls** - Use Provider or other state management
5. **Missing RepaintBoundary** - Already implemented in our optimized widgets

## Recommended Testing Workflow

1. **Development**: Use `flutter run` for quick testing
2. **Performance Analysis**: Use `flutter run --profile` with DevTools
3. **Final Testing**: Use `flutter build apk --release` and test on real devices
4. **Monitoring**: Check console logs for PerformanceMonitor reports

## Performance Targets
- **Target FPS**: 60fps (16.67ms per frame)
- **Maximum Jank**: <5% of frames
- **App Startup**: <3 seconds to interactive
- **Memory Usage**: <200MB for typical usage
