@echo off
echo Building Sitara777 APK...

REM Set environment variables to handle path issues
set GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

REM Clean and build
flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons

echo Build completed!
pause
