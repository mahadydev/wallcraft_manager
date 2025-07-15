import 'dart:typed_data';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';
import 'wallcraft_manager_platform_interface.dart';

/// A Flutter plugin for setting wallpapers and saving images to gallery.
///
/// This plugin provides functionality to:
/// - Set wallpapers on Android devices
/// - Save images to device gallery on both Android and iOS
/// - Handle different wallpaper types (home, lock, both)
///
/// ## Platform Support
/// - **Android**: Full wallpaper setting support
/// - **iOS**: Gallery saving only (requires manual user action)
///
/// ## Required Permissions
/// ### Android
/// - `SET_WALLPAPER`: Required for setting wallpapers
/// - `WRITE_EXTERNAL_STORAGE`: Required for saving to gallery (API < 29)
/// - `READ_EXTERNAL_STORAGE`: Required for reading image files
///
/// ### iOS
/// - `NSPhotoLibraryAddUsageDescription`: Required for saving to Photos
///
/// ## Usage Example
/// ```dart
/// final wallcraftManager = WallcraftManager();
///
/// // Check if wallpaper setting is supported
/// bool isSupported = await wallcraftManager.isSupported();
///
/// // Set wallpaper from file
/// bool success = await wallcraftManager.setWallpaperFromFile(
///   filePath: '/path/to/image.jpg',
///   type: WallpaperSetterType.home,
/// );
///
/// // Save image to gallery
/// bool saved = await wallcraftManager.saveImageToGalleryFromFile(
///   filePath: '/path/to/image.jpg',
/// );
/// ```
class WallcraftManager {
  /// Check if setting wallpaper is supported on the current platform.
  ///
  /// Returns `true` on Android devices, `false` on iOS devices.
  /// iOS doesn't support programmatic wallpaper setting due to limitations.
  Future<bool> isSupported() {
    return WallcraftManagerPlatform.instance.isSupported();
  }

  /// Set wallpaper from a file path.
  ///
  /// [filePath] - The absolute path to the image file
  /// [type] - The type of wallpaper to set (home, lock, or both)
  ///
  /// Returns `true` if successful, `false` otherwise.
  ///
  /// **Android**: Sets the wallpaper as requested
  /// **iOS**: Saves to Photos and shows instructions to user
  ///
  /// Throws [PlatformException] if:
  /// - File doesn't exist or can't be read
  /// - Invalid image format
  /// - Permission denied
  /// - Wallpaper type not supported on device
  Future<bool> setWallpaperFromFile({
    required String filePath,
    required WallpaperSetterType type,
  }) {
    return WallcraftManagerPlatform.instance.setWallpaperFromFile(
      filePath: filePath,
      type: type,
    );
  }

  /// Set wallpaper from image bytes.
  ///
  /// [bytes] - The image data as bytes
  /// [type] - The type of wallpaper to set (home, lock, or both)
  ///
  /// Returns `true` if successful, `false` otherwise.
  ///
  /// **Android**: Sets the wallpaper as requested
  /// **iOS**: Saves to Photos and shows instructions to user
  ///
  /// Throws [PlatformException] if:
  /// - Invalid image data
  /// - Permission denied
  /// - Wallpaper type not supported on device
  Future<bool> setWallpaperFromBytes({
    required Uint8List bytes,
    required WallpaperSetterType type,
  }) {
    return WallcraftManagerPlatform.instance.setWallpaperFromBytes(
      bytes: bytes,
      type: type,
    );
  }

  /// Save an image to the device's gallery from a file path.
  ///
  /// [filePath] - The absolute path to the image file
  ///
  /// Returns `true` if successful, `false` otherwise.
  ///
  /// **Android**: Saves to Pictures/Wallcraft folder
  /// **iOS**: Saves to Photos app in Wallcraft album
  ///
  /// Throws [PlatformException] if:
  /// - File doesn't exist or can't be read
  /// - Invalid image format
  /// - Permission denied
  /// - Storage full
  Future<bool> saveImageToGalleryFromFile({required String filePath}) {
    return WallcraftManagerPlatform.instance.saveImageToGalleryFromFile(
      filePath: filePath,
    );
  }

  /// Save an image to the device's gallery from image bytes.
  ///
  /// [bytes] - The image data as bytes
  ///
  /// Returns `true` if successful, `false` otherwise.
  ///
  /// **Android**: Saves to Pictures/Wallcraft folder
  /// **iOS**: Saves to Photos app in Wallcraft album
  ///
  /// Throws [PlatformException] if:
  /// - Invalid image data
  /// - Permission denied
  /// - Storage full
  Future<bool> saveImageToGalleryFromBytes({required Uint8List bytes}) {
    return WallcraftManagerPlatform.instance.saveImageToGalleryFromBytes(
      bytes: bytes,
    );
  }
}
