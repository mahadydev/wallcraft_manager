# Wallcraft Manager

A Flutter plugin for setting wallpapers and saving images to gallery on Android and iOS.

## Features

- ✅ Set wallpapers on Android (home screen, lock screen, or both)
- ✅ Save images to device gallery on both platforms
- ✅ Support for both file paths and image bytes
- ✅ Proper error handling and permission management
- ✅ Modern Android API support (MediaStore for Android 10+)
- ✅ iOS Photos framework integration

## Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Set Wallpaper | ✅ | ❌* |
| Save to Gallery | ✅ | ✅ |

*iOS doesn't support programmatic wallpaper setting due to platform limitations. The plugin will save the image to Photos and show instructions to the user.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  wallcraft_manager: ^latest_version
```

## Setup

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SET_WALLPAPER" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to save images to your photo library.</string>
```

## Usage

```dart
import 'package:wallcraft_manager/wallcraft_manager.dart';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';

final wallcraftManager = WallcraftManager();

// Check if wallpaper setting is supported
bool isSupported = await wallcraftManager.isSupported();

// Set wallpaper from file
bool success = await wallcraftManager.setWallpaperFromFile(
  filePath: '/path/to/image.jpg',
  type: WallpaperSetterType.home,
);

// Set wallpaper from bytes
bool success = await wallcraftManager.setWallpaperFromBytes(
  bytes: imageBytes,
  type: WallpaperSetterType.both,
);

// Save image to gallery
bool saved = await wallcraftManager.saveImageToGalleryFromFile(
  filePath: '/path/to/image.jpg',
);
```

## Error Handling

The plugin throws `PlatformException` with the following error codes:

- `INVALID_ARGUMENT`: Missing or invalid parameters
- `FILE_NOT_FOUND`: Image file doesn't exist
- `PERMISSION_DENIED`: Missing required permissions
- `INVALID_IMAGE`: Invalid image format or corrupted data
- `SAVE_ERROR`: Failed to save image to gallery
- `SET_WALLPAPER_ERROR`: Failed to set wallpaper

```dart
try {
  bool success = await wallcraftManager.setWallpaperFromFile(
    filePath: imagePath,
    type: WallpaperSetterType.home,
  );
} on PlatformException catch (e) {
  print('Error: ${e.code} - ${e.message}');
}
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## License

MIT License - see LICENSE file for details.