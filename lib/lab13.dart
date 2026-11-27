import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const DiaryScreen(),
    );
  }
}

class DiaryEntry {
  final String imagePath;
  final String caption;
  final double? latitude;
  final double? longitude;
  final DateTime time;

  const DiaryEntry({
    required this.imagePath,
    required this.caption,
    required this.latitude,
    required this.longitude,
    required this.time,
  });
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _picker = ImagePicker();
  final _captionController = TextEditingController();

  File? _image;
  Position? _position;
  DateTime? _gpsTime;
  bool _isLoading = false;
  final List<DiaryEntry> _entries = [];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (picked == null) return;

      setState(() => _image = File(picked.path));
    } catch (e) {
      _showMessage('Cannot open camera or gallery');
    }
  }

  Future<void> _fetchGps() async {
    setState(() => _isLoading = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showMessage(
          'Please enable GPS on your device',
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Geolocator.openLocationSettings(),
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission denied forever. Enable it in app settings',
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _position = position;
        _gpsTime = DateTime.now();
      });
    } catch (e) {
      _showMessage('GPS error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveEntry() {
    final caption = _captionController.text.trim();

    if (_image == null || caption.isEmpty) {
      _showMessage('Select a photo and enter a caption');
      return;
    }

    setState(() {
      _entries.insert(
        0,
        DiaryEntry(
          imagePath: _image!.path,
          caption: caption,
          latitude: _position?.latitude,
          longitude: _position?.longitude,
          time: DateTime.now(),
        ),
      );
      _image = null;
      _position = null;
      _gpsTime = null;
      _captionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Narxoz Photo Journal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _image == null
                  ? const Center(
                child: Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              )
                  : Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 16),

          Text('Latitude: ${_position?.latitude.toStringAsFixed(6) ?? '-'}'),
          Text('Longitude: ${_position?.longitude.toStringAsFixed(6) ?? '-'}'),
          Text('Accuracy: ${_position != null ? '± ${_position!.accuracy.toStringAsFixed(1)} m' : '-'}'),
          Text('Timestamp: ${_gpsTime?.toString().substring(0, 19) ?? '-'}'),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Pick Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchGps,
                child: const Text('Fetch Current GPS Location'),
              ),
            ),
          const SizedBox(height: 16),

          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save Entry to Diary'),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Diary Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No entries yet')),
            ),
          ..._entries.map((entry) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entry.imagePath),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(entry.caption),
              isThreeLine: true,
              subtitle: Text(
                '${entry.latitude != null ? '${entry.latitude!.toStringAsFixed(4)}° N, ${entry.longitude!.toStringAsFixed(4)}° E' : 'No GPS'}\n'
                    '${entry.time.toString().substring(0, 16)}',
              ),
            );
          }),
        ],
      ),
    );
  }
}