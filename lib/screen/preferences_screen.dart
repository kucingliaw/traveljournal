import 'package:flutter/material.dart';
import 'package:traveljournal/services/local_database_service.dart';
import 'package:traveljournal/auth/auth_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _localDb = LocalDatabaseService();
  final _authService = AuthService();
  bool _isLoading = true;
  List<String> _selectedDestinations = [];
  String _selectedTravelStyle = '';
  List<String> _selectedInterests = [];

  final List<String> _travelStyles = [
    'Adventure',
    'Relaxation',
    'Cultural',
    'Food & Wine',
    'Budget',
    'Luxury',
  ];

  final List<String> _destinations = [
    'Beach',
    'Mountains',
    'Cities',
    'Countryside',
    'Islands',
    'Historical Sites',
  ];

  final List<String> _interests = [
    'Photography',
    'Local Food',
    'Museums',
    'Nature',
    'Shopping',
    'Architecture',
    'Music',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final prefs = await _localDb.getPreferences(user.id);
        if (prefs != null) {
          setState(() {
            _selectedDestinations = (prefs['preferred_destinations'] as String)
                .split(',');
            _selectedTravelStyle = prefs['travel_style'] as String;
            _selectedInterests = (prefs['interests'] as String).split(',');
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        await _localDb.savePreferences(user.id, {
          'preferred_destinations': _selectedDestinations.join(','),
          'travel_style': _selectedTravelStyle,
          'interests': _selectedInterests.join(','),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
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
        surfaceTintColor: Colors.white,
        title: const Text('Travel Preferences'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePreferences,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Preferred Destinations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _destinations.map((destination) {
                    return FilterChip(
                      label: Text(destination),
                      selected: _selectedDestinations.contains(destination),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDestinations.add(destination);
                          } else {
                            _selectedDestinations.remove(destination);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Travel Style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _travelStyles.map((style) {
                    return ChoiceChip(
                      label: Text(style),
                      selected: _selectedTravelStyle == style,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTravelStyle = selected ? style : '';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Interests',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _interests.map((interest) {
                    return FilterChip(
                      label: Text(interest),
                      selected: _selectedInterests.contains(interest),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
