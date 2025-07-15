// lib/enum/wallpaper_setter_type.dart
/// Enum representing different types of wallpaper settings.
enum WallpaperSetterType {
  /// Set wallpaper for home screen only
  home,

  /// Set wallpaper for lock screen only
  /// Note: Only supported on Android API 24+ (Android 7.0+)
  lock,

  /// Set wallpaper for both home and lock screens
  both,
}

extension WallpaperSetterTypeExtension on WallpaperSetterType {
  /// Returns the integer value for the enum used in platform channels
  int get index {
    switch (this) {
      case WallpaperSetterType.home:
        return 0;
      case WallpaperSetterType.lock:
        return 1;
      case WallpaperSetterType.both:
        return 2;
    }
  }

  /// Returns a human-readable description of the wallpaper type
  String get description {
    switch (this) {
      case WallpaperSetterType.home:
        return 'Home Screen';
      case WallpaperSetterType.lock:
        return 'Lock Screen';
      case WallpaperSetterType.both:
        return 'Both Screens';
    }
  }
}
