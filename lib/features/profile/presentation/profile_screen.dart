import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveljournal/services/profile_service.dart';
import 'package:traveljournal/features/auth/data/auth_service.dart';
import 'package:traveljournal/features/profile/models/user_profile.dart';
import 'package:traveljournal/features/auth/presentation/login_screen.dart';
import 'package:traveljournal/features/profile/presentation/preferences_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:traveljournal/widgets/loading_display.dart';
import 'package:traveljournal/widgets/error_display.dart';
import 'package:traveljournal/utils/ui_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          if (profile?.username != null) {
            _usernameController.text = profile!.username!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error loading profile: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      showErrorSnackbar(context, 'Please enter a username');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedProfile = await _profileService.upsertProfile(
        username: _usernameController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _profile = updatedProfile;
          _isSaving = false;
        });
        showSuccessSnackbar(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error updating profile: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    setState(() => _isSaving = true);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final updatedProfile = await _profileService.upsertProfile(
          username: _profile?.username,
          avatarFile: File(image.path),
        );

        if (mounted) {
          setState(() {
            _profile = updatedProfile;
            _isSaving = false;
          });
          showSuccessSnackbar(context, 'Profile photo updated successfully');
        }
      } else {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showErrorSnackbar(context, 'Error updating profile photo: $e');
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isSaving = true);
    try {
      await _profileService.deleteAvatar();
      await _loadProfile(); // Reload profile to get updated data
      if (mounted) {
        setState(() => _isSaving = false);
        showSuccessSnackbar(context, 'Profile photo removed successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showErrorSnackbar(context, 'Error removing profile photo: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error signing out: $e');
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
        title: const Text('Profile'),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const LoadingDisplay(message: 'Loading profile...')
          : _profile == null
          ? ErrorDisplay(
              message: 'Could not load profile',
              onRetry: _loadProfile,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(
                    isSaving: _isSaving,
                    profile: _profile,
                    onPickImage: _pickImage,
                    onRemoveAvatar: _removeAvatar,
                  ),
                  if (_profile?.avatarUrl != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _isSaving ? null : _removeAvatar,
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove Photo'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    _profile?.email ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _updateProfile,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Travel Preferences'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _signOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final bool isSaving;
  final UserProfile? profile;
  final VoidCallback? onPickImage;
  final VoidCallback? onRemoveAvatar;

  const _ProfileAvatar({
    required this.isSaving,
    required this.profile,
    this.onPickImage,
    this.onRemoveAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: isSaving
              ? const LoadingDisplay()
              : _buildProfileImage(context),
        ),
        if (!isSaving)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: Icon(
                  profile?.avatarUrl != null ? Icons.edit : Icons.add_a_photo,
                  color: Colors.white,
                ),
                onPressed: onPickImage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    if (profile?.avatarUrl == null) {
      return const Icon(Icons.person, size: 40, color: Colors.grey);
    }
    final imageUrl =
        '${profile!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      memCacheWidth: 800,
      memCacheHeight: 800,
      fadeInDuration: const Duration(milliseconds: 300),
      cacheKey: imageUrl.split('?').first,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
      placeholder: (context, url) => const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }
}
