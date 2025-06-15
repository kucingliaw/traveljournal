import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveljournal/utils/ui_helper.dart';

class JournalImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final String? initialImageUrl;
  final ValueChanged<String?> onImagePathChanged;

  const JournalImagePicker({
    super.key,
    this.initialImagePath,
    this.initialImageUrl,
    required this.onImagePathChanged,
  });

  @override
  State<JournalImagePicker> createState() => _JournalImagePickerState();
}

class _JournalImagePickerState extends State<JournalImagePicker> {
  String? _imagePath;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _currentImageUrl = null; // Clear current URL if new image is picked
        });
        widget.onImagePathChanged(_imagePath);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to pick image: $e');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _currentImageUrl = null;
    });
    widget.onImagePathChanged(null);
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromSource(ImageSource.gallery);
              },
            ),
            if (_imagePath != null || _currentImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.photo),
          label: Text(
            _imagePath == null && _currentImageUrl == null
                ? 'Add Photo'
                : 'Change Photo',
          ),
        ),
        if (_imagePath != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_imagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ] else if (_currentImageUrl != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _currentImageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
} 