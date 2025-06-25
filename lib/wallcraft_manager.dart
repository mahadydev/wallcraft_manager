import 'dart:typed_data';

import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';

import 'wallcraft_manager_platform_interface.dart';

class WallcraftManager {
  /// Check if setting wallpaper is supported
  Future<bool> isSupported() {
    return WallcraftManagerPlatform.instance.isSupported();
  }

  /// Set wallpaper from file path
  Future<bool> setWallpaperFromFile({
    required String filePath,
    required WallpaperSetterType type,
  }) {
    return WallcraftManagerPlatform.instance.setWallpaperFromFile(
      filePath: filePath,
      type: type,
    );
  }

  /// Set wallpaper from bytes
  Future<bool> setWallpaperFromBytes({
    required Uint8List bytes,
    required WallpaperSetterType type,
  }) {
    return WallcraftManagerPlatform.instance.setWallpaperFromBytes(
      bytes: bytes,
      type: type,
    );
  }

  /// Save an image to the device's gallery
  Future<bool> saveImageToGalleryFromFile({required String filePath}) {
    return WallcraftManagerPlatform.instance.saveImageToGalleryFromFile(
      filePath: filePath,
    );
  }

  /// Save an image to the device's gallery
  Future<bool> saveImageToGalleryFromBytes({required Uint8List bytes}) {
    return WallcraftManagerPlatform.instance.saveImageToGalleryFromBytes(
      bytes: bytes,
    );
  }
}
