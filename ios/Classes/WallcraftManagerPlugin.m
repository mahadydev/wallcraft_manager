# ios/Classes/WallcraftManagerPlugin.m (Objective-C registration)
#import "WallcraftManagerPlugin.h"
#if __has_include(<wallcraft_manager/wallcraft_manager-Swift.h>)
#import <wallcraft_manager/wallcraft_manager-Swift.h>
#else
#import "wallcraft_manager-Swift.h"
#endif

@implementation WallcraftManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWallcraftManagerPlugin registerWithRegistrar:registrar];
}
@end