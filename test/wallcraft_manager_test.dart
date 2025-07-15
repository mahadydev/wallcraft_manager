import 'package:flutter_test/flutter_test.dart';
import 'package:wallcraft_manager/wallcraft_manager.dart';
import 'package:wallcraft_manager/wallcraft_manager_platform_interface.dart';
import 'package:wallcraft_manager/wallcraft_manager_method_channel.dart';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:typed_data';

class MockWallcraftManagerPlatform
    with MockPlatformInterfaceMixin
    implements WallcraftManagerPlatform {
  @override
  Future<bool> isSupported() => Future.value(true);

  @override
  Future<bool> setWallpaperFromFile({
    required String filePath,
    required WallpaperSetterType type,
  }) =>
      Future.value(true);

  @override
  Future<bool> setWallpaperFromBytes({
    required Uint8List bytes,
    required WallpaperSetterType type,
  }) =>
      Future.value(true);

  @override
  Future<bool> saveImageToGalleryFromFile({
    required String filePath,
  }) =>
      Future.value(true);

  @override
  Future<bool> saveImageToGalleryFromBytes({
    required Uint8List bytes,
  }) =>
      Future.value(true);
}

void main() {
  final WallcraftManagerPlatform initialPlatform =
      WallcraftManagerPlatform.instance;

  test('$MethodChannelWallcraftManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWallcraftManager>());
  });

  test('isSupported', () async {
    final WallcraftManager wallcraftManagerPlugin = WallcraftManager();
    final MockWallcraftManagerPlatform fakePlatform =
        MockWallcraftManagerPlatform();
    WallcraftManagerPlatform.instance = fakePlatform;

    expect(await wallcraftManagerPlugin.isSupported(), true);
  });

  test('setWallpaperFromFile', () async {
    final WallcraftManager wallcraftManagerPlugin = WallcraftManager();
    final MockWallcraftManagerPlatform fakePlatform =
        MockWallcraftManagerPlatform();
    WallcraftManagerPlatform.instance = fakePlatform;

    expect(
      await wallcraftManagerPlugin.setWallpaperFromFile(
        filePath: '/test/path',
        type: WallpaperSetterType.home,
      ),
      true,
    );
  });

  test('saveImageToGalleryFromFile', () async {
    final WallcraftManager wallcraftManagerPlugin = WallcraftManager();
    final MockWallcraftManagerPlatform fakePlatform =
        MockWallcraftManagerPlatform();
    WallcraftManagerPlatform.instance = fakePlatform;

    expect(
      await wallcraftManagerPlugin.saveImageToGalleryFromFile(
        filePath: '/test/path',
      ),
      true,
    );
  });
}
