import Flutter
import UIKit

public class SwiftWallcraftManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    WallcraftManagerPlugin.register(with: registrar)
  }
}