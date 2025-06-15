import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:traveljournal/services/journal_service.dart';
import 'package:traveljournal/models/journal.dart';
import 'package:traveljournal/utils/validation_helper.dart';
import 'package:traveljournal/widgets/loading_display.dart';
import 'package:traveljournal/services/location_service.dart';

class JournalFormScreen extends StatefulWidget {
  final Journal? journal; // If provided, we're editing an existing journal

  const JournalFormScreen({super.key, this.journal});

  @override
  State<JournalFormScreen> createState() => _JournalFormScreenState();
}

class _JournalFormScreenState extends State<JournalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;
  String? _currentImageUrl; // For existing image
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  final _journalService = JournalService();

  @override
  void initState() {
    super.initState();
    if (widget.journal != null) {
      // We're editing an existing journal
      _titleController.text = widget.journal!.title;
      _contentController.text = widget.journal!.content;
      _currentImageUrl = widget.journal!.imageUrl;
      _locationName = widget.journal!.locationName;
      _latitude = widget.journal!.latitude;
      _longitude = widget.journal!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentLocation(context);
    if (position == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        final locationName = [
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _locationName = locationName;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.journal != null) {
        // Update existing journal
        await _journalService.updateJournal(
          id: widget.journal!.id,
          title: _titleController.text,
          content: _contentController.text,
          imagePath: _imagePath,
          currentImageUrl: _currentImageUrl,
          locationName: _locationName,
          latitude: _latitude,
          longitude: _longitude,
        );
      } else {
        // Create new journal
        await _journalService.createJournal(
          title: _titleController.text,
          content: _contentController.text,
          imagePath: _imagePath,
          locationName: _locationName,
          latitude: _latitude,
          longitude: _longitude,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.journal == null
                  ? 'Journal created successfully!'
                  : 'Journal updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save journal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.journal == null ? 'New Journal Entry' : 'Edit Journal Entry',
        ),
      ),
      body: _isLoading
          ? const LoadingDisplay(message: 'Saving journal...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: ValidationHelper.validateTitle,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: ValidationHelper.validateContent,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        _locationName == null
                            ? 'Add Location'
                            : 'Change Location',
                      ),
                    ),
                    if (_locationName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _locationName!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saveJournal,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.journal == null
                              ? 'Create Journal'
                              : 'Update Journal',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
