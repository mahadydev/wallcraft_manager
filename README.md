# Wallcraft Manager Flutter Plugin

A Flutter plugin to set wallpapers (home, lock, or both) and save images to the gallery on Android (and iOS, if implemented). Supports setting wallpapers from file or bytes, and saving images to the gallery with full Android 10+ and legacy support.

## Features
- Set wallpaper from file or bytes (home, lock, or both)
- Save images to the gallery (Android 10+ and <10 supported)
- Handles permissions and errors gracefully
- Example app with image preview, download, and set wallpaper actions

## Getting Started

### 1. Add dependency
```yaml
dependencies:
  wallcraft_manager:
```

### 2. Android Setup
- Add the following permission to your app's `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  ```
- For Android < 10, request storage permission at runtime (see example).

### 3. Usage Example
```dart
final wallcraftManager = WallcraftManager();

// Set wallpaper from bytes
await wallcraftManager.setWallpaperFromBytes(
  bytes: imageBytes,
  type: WallpaperSetterType.homeScreen, // or lockScreen, both
);

// Save image to gallery
await wallcraftManager.saveImageToGalleryFromBytes(bytes: imageBytes);
```

See the `example/` app for a complete UI and permission handling.

## Example UI
- Pick or load an image
- Preview in detail screen
- Set as home/lock/both wallpaper
- Save image to gallery

## License
MIT

