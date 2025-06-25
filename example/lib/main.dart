import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallcraft_manager/wallcraft_manager.dart';
import 'package:wallcraft_manager/enum/wallpaper_setter_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WallcraftManagerExampleApp());
}

class WallcraftManagerExampleApp extends StatelessWidget {
  const WallcraftManagerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallcraft Manager Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Example image URL (replace with your own or make dynamic)
  final String imageUrl =
      'https://images.pexels.com/photos/29145098/pexels-photo-29145098.jpeg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallcraft Manager Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap to view image details',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageDetailScreen(imageUrl: imageUrl),
                  ),
                );
              },
              child: Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 200,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDetailScreen extends StatefulWidget {
  final String imageUrl;
  const ImageDetailScreen({super.key, required this.imageUrl});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final WallcraftManager wallcraftManager = WallcraftManager();
  bool _downloading = false;
  String _status = '';

  Future<bool> _ensureStoragePermission() async {
    if (await Permission.storage.isGranted) return true;
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<Uint8List?> _downloadImageBytes() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _setWallpaper(WallpaperSetterType type) async {
    setState(() {
      _downloading = true;
      _status = 'Downloading image...';
    });
    final bytes = await _downloadImageBytes();
    if (bytes == null) {
      setState(() {
        _downloading = false;
        _status = 'Failed to download image.';
      });
      return;
    }
    setState(() {
      _status = 'Setting wallpaper...';
    });
    try {
      final result = await wallcraftManager.setWallpaperFromBytes(
        bytes: bytes,
        type: type,
      );
      setState(() {
        _downloading = false;
        _status = result ? 'Wallpaper set!' : 'Failed to set wallpaper.';
      });
    } catch (e) {
      setState(() {
        _downloading = false;
        _status = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _downloadSaveImageToGallery() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    int androidVersion = int.parse(androidInfo.version.sdkInt.toString());
    if (Platform.isAndroid && androidVersion < 29) {
      final granted = await _ensureStoragePermission();
      if (!granted) {
        setState(() => _status = 'Storage permission denied.');
        return;
      }
    }
    setState(() {
      _downloading = true;
      _status = 'Downloading image...';
    });
    final bytes = await _downloadImageBytes();
    if (bytes == null) {
      setState(() {
        _downloading = false;
        _status = 'Failed to download image.';
      });
      return;
    }
    try {
      final result = await wallcraftManager.saveImageToGalleryFromBytes(
        bytes: bytes,
      );
      if (!result) {
        setState(() {
          _downloading = false;
          _status = 'Failed to save image to gallery.';
        });
        return;
      }
      setState(() {
        _downloading = false;
        _status = 'Image saved to gallery.';
      });
    } catch (e) {
      setState(() {
        _downloading = false;
        _status = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Details')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: widget.imageUrl,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_downloading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloading
                        ? null
                        : () => _setWallpaper(WallpaperSetterType.homeScreen),
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('Set as Home Screen'),
                  ),

                  ElevatedButton.icon(
                    onPressed: _downloading
                        ? null
                        : () => _setWallpaper(WallpaperSetterType.lockScreen),
                    icon: const Icon(Icons.lock),
                    label: const Text('Set as Lock Screen'),
                  ),

                  ElevatedButton.icon(
                    onPressed: _downloading
                        ? null
                        : () => _setWallpaper(WallpaperSetterType.both),
                    icon: const Icon(Icons.screen_lock_landscape),
                    label: const Text('Set as Both'),
                  ),

                  OutlinedButton.icon(
                    onPressed: _downloading
                        ? null
                        : _downloadSaveImageToGallery,
                    icon: const Icon(Icons.save_as),
                    label: const Text('Save Image to Gallery'),
                  ),

                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
