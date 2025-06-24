import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:wallcraft_manager/wallcraft_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isSupported test', (WidgetTester tester) async {
    final WallcraftManager plugin = WallcraftManager();
    final bool isSupported = await plugin.isSupported();
    // The isSupported method returns a boolean indicating support.
    expect(Platform.isAndroid ? isSupported : true, false);
  });
}
