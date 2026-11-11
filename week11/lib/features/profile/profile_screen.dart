import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.prefs, super.key});

  final SharedPreferencesAsync prefs;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvatar());
  }

  Future<void> _loadAvatar() async {
    final path = await widget.prefs.getString('avatarPath');
    if (!mounted) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _chooseGallery() => _pick(ImageSource.gallery);

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _showMessage('Camera permission was denied.');
      case PermissionStatus.permanentlyDenied:
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera permission'),
            content: const Text(
              'Camera access is blocked. Open app settings to allow it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (!mounted || openSettings != true) return;
        await openAppSettings();
        if (!mounted) return;
      case PermissionStatus.restricted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        _showMessage('Camera access is restricted on this device.');
    }
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    await _saveAvatar(picked.path);
  }

  Future<void> _saveAvatar(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final target = File('${directory.path}${Platform.pathSeparator}avatar.jpg');
    await File(sourcePath).copy(target.path);
    await widget.prefs.setString('avatarPath', target.path);
    if (!mounted) return;
    setState(() => _avatarPath = target.path);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final path = _avatarPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file?.existsSync() ?? false;
    final image = file == null || !hasPhoto ? null : FileImage(file);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundImage: image,
              child: hasPhoto ? null : const Icon(Icons.person, size: 56),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _chooseGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose photo'),
          ),
          OutlinedButton.icon(
            onPressed: _requestCamera,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Take photo'),
          ),
        ],
      ),
    );
  }
}
