import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';

import 'wallcraft_manager_platform_interface.dart';

/// An implementation of [WallcraftManagerPlatform] that uses method channels.
class MethodChannelWallcraftManager extends WallcraftManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wallcraft_manager');

  @override
  Future<bool> setWallpaperFromFile({
    required String filePath,
    required WallpaperSetterType type,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setWallpaperFromFile',
      {'filePath': filePath, 'type': type.index},
    );
    return result ?? false;
  }

  @override
  Future<bool> setWallpaperFromBytes({
    required Uint8List bytes,
    required WallpaperSetterType type,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setWallpaperFromBytes',
      {'bytes': bytes, 'type': type.index},
    );
    return result ?? false;
  }

  @override
  Future<bool> isSupported() async {
    final result = await methodChannel.invokeMethod<bool>('isSupported');
    return result ?? false;
  }
}
