import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:traveljournal/models/journal.dart';
import 'package:traveljournal/services/journal_service.dart';
import 'package:traveljournal/screen/journal_form_screen.dart';

class JournalDetailsScreen extends StatefulWidget {
  final Journal journal;

  const JournalDetailsScreen({super.key, required this.journal});

  @override
  State<JournalDetailsScreen> createState() => _JournalDetailsScreenState();
}

class _JournalDetailsScreenState extends State<JournalDetailsScreen> {
  final JournalService _journalService = JournalService();
  bool _isDeleting = false;

  Future<void> _deleteJournal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await _journalService.deleteJournal(widget.journal);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal deleted successfully')),
          );
          Navigator.pop(context, true); // Return true to trigger list refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete journal: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  void _editJournal() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => JournalFormScreen(journal: widget.journal),
      ),
    );

    if (updated == true && mounted) {
      Navigator.pop(context, true); // Return true to trigger list refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');
    final timeFormat = DateFormat('h:mm a');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: kToolbarHeight + 24,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: const Text('Journal Details'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: IconButton(
              onPressed: _editJournal,
              icon: const Icon(Icons.edit),
            ),
          ),
          if (!_isDeleting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: IconButton(
                onPressed: _deleteJournal,
                icon: const Icon(Icons.delete),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.journal.imageUrl != null)
              Hero(
                tag: 'journal_image_${widget.journal.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.journal.imageUrl!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.journal.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (widget.journal.locationName != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.journal.locationName!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(widget.journal.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat.format(widget.journal.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.journal.content,
                    style: Theme.of(context).textTheme.bodyLarge,
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
