import 'package:flutter/material.dart';
import 'package:wallcraft_manager/wallcraft_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WallcraftManager wallcraftManager = WallcraftManager();

  @override
  void initState() {
    wallcraftManager.isSupported().then((isSupported) {
      print('Wallcraft Manager is supported: $isSupported');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallcraft Manager Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Wallcraft Manager Example')),
        body: Center(
          child: const Text('Welcome to Wallcraft Manager Example!'),
        ),
      ),
    );
  }
}
