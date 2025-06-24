import 'package:flutter_test/flutter_test.dart';
import 'package:wallcraft_manager/wallcraft_manager.dart';
import 'package:wallcraft_manager/wallcraft_manager_platform_interface.dart';
import 'package:wallcraft_manager/wallcraft_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWallcraftManagerPlatform
    with MockPlatformInterfaceMixin
    implements WallcraftManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WallcraftManagerPlatform initialPlatform = WallcraftManagerPlatform.instance;

  test('$MethodChannelWallcraftManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWallcraftManager>());
  });

  test('getPlatformVersion', () async {
    WallcraftManager wallcraftManagerPlugin = WallcraftManager();
    MockWallcraftManagerPlatform fakePlatform = MockWallcraftManagerPlatform();
    WallcraftManagerPlatform.instance = fakePlatform;

    expect(await wallcraftManagerPlugin.getPlatformVersion(), '42');
  });
}
