import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';

import 'wallcraft_manager_method_channel.dart';

abstract class WallcraftManagerPlatform extends PlatformInterface {
  /// Constructs a WallcraftManagerPlatform.
  WallcraftManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static WallcraftManagerPlatform _instance = MethodChannelWallcraftManager();

  /// The default instance of [WallcraftManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelWallcraftManager].
  static WallcraftManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WallcraftManagerPlatform] when
  /// they register themselves.
  static set instance(WallcraftManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  Future<bool> setWallpaperFromFile({
    required String filePath,
    required WallpaperSetterType type,
  }) {
    throw UnimplementedError(
      'setWallpaperFromFile() has not been implemented.',
    );
  }

  Future<bool> setWallpaperFromBytes({
    required Uint8List bytes,
    required WallpaperSetterType type,
  }) {
    throw UnimplementedError(
      'setWallpaperFromBytes() has not been implemented.',
    );
  }

  Future<bool> saveImageToGalleryFromFile({required String filePath}) {
    throw UnimplementedError(
      'saveImageToGalleryFromFile() has not been implemented.',
    );
  }

  Future<bool> saveImageToGalleryFromBytes({required Uint8List bytes}) {
    throw UnimplementedError(
      'saveImageToGalleryFromBytes() has not been implemented.',
    );
  }
}
