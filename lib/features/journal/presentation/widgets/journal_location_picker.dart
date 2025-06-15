import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:traveljournal/features/journal/data/location_service.dart';
import 'package:traveljournal/utils/ui_helper.dart';

class JournalLocationPicker extends StatefulWidget {
  final String? initialLocationName;
  final ValueChanged<String?> onLocationNameChanged;
  final ValueChanged<double?> onLatitudeChanged;
  final ValueChanged<double?> onLongitudeChanged;

  const JournalLocationPicker({
    super.key,
    this.initialLocationName,
    required this.onLocationNameChanged,
    required this.onLatitudeChanged,
    required this.onLongitudeChanged,
  });

  @override
  State<JournalLocationPicker> createState() => _JournalLocationPickerState();
}

class _JournalLocationPickerState extends State<JournalLocationPicker> {
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _locationName = widget.initialLocationName;
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
        });
        widget.onLocationNameChanged(_locationName);
        widget.onLatitudeChanged(position.latitude);
        widget.onLongitudeChanged(position.longitude);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Failed to get location: $e');
      }
    }
  }

  void _removeLocation() {
    setState(() {
      _locationName = null;
    });
    widget.onLocationNameChanged(null);
    widget.onLatitudeChanged(null);
    widget.onLongitudeChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _getCurrentLocation,
          icon: const Icon(Icons.location_on),
          label: Text(
            _locationName == null ? 'Add Location' : 'Change Location',
          ),
        ),
        if (_locationName != null) ...[
          const SizedBox(height: 8),
          Text(
            _locationName!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _removeLocation,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Remove Location', style: TextStyle(color: Colors.red)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ],
    );
  }
} 