import 'package:flutter/material.dart';
import 'package:traveljournal/features/journal/data/journal_service.dart';
import 'package:traveljournal/features/journal/models/journal.dart';
import 'package:traveljournal/utils/validation_helper.dart';
import 'package:traveljournal/widgets/loading_display.dart';
import 'package:traveljournal/utils/ui_helper.dart';
import 'package:traveljournal/features/journal/presentation/widgets/journal_image_picker.dart';
import 'package:traveljournal/features/journal/presentation/widgets/journal_location_picker.dart';

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
  String? _currentImageUrl;
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
        showSuccessSnackbar(
          context,
          widget.journal == null
              ? 'Journal created successfully!'
              : 'Journal updated successfully!',
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to save journal: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
      ),
      validator: ValidationHelper.validateTitle,
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Content',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      validator: ValidationHelper.validateContent,
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _saveJournal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.journal == null ? 'Create Journal' : 'Update Journal',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.journal == null ? 'New Journal Entry' : 'Edit Journal Entry',
        ),
      ),
      body: _isLoading
          ? LoadingDisplay(message: 'Saving journal...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleField(),
                    SizedBox(height: 16),
                    _buildContentField(),
                    SizedBox(height: 16),
                    JournalImagePicker(
                      initialImagePath: _imagePath,
                      initialImageUrl: _currentImageUrl,
                      onImagePathChanged: (path) {
                        setState(() {
                          _imagePath = path;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    JournalLocationPicker(
                      initialLocationName: _locationName,
                      onLocationNameChanged: (name) {
                        setState(() {
                          _locationName = name;
                        });
                      },
                      onLatitudeChanged: (lat) {
                        setState(() {
                          _latitude = lat;
                        });
                      },
                      onLongitudeChanged: (lon) {
                        setState(() {
                          _longitude = lon;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }
}
