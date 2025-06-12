import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveljournal/services/profile_service.dart';
import 'package:traveljournal/auth/auth_service.dart';
import 'package:traveljournal/models/user_profile.dart';
import 'package:traveljournal/screen/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    if (_isSaving) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      );
    }

    if (_profile?.avatarUrl == null) {
      return const Icon(Icons.person, size: 40, color: Colors.grey);
    }

    final imageUrl =
        '${_profile!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}';
    print('Loading profile image from URL: $imageUrl'); // Debug log

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      memCacheWidth: 800,
      memCacheHeight: 800,
      fadeInDuration: const Duration(milliseconds: 300),
      cacheKey: imageUrl
          .split('?')
          .first, // Cache by base URL without timestamp
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
      errorWidget: (context, url, error) {
        print(
          'Error loading profile image: $error from URL: $url',
        ); // Debug log
        return const Icon(Icons.person, size: 40, color: Colors.grey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
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
                        child: _buildProfileImage(),
                      ),
                      if (!_isSaving)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: Icon(
                                _profile?.avatarUrl != null
                                    ? Icons.edit
                                    : Icons.add_a_photo,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                    ],
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
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _signOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('Sign Out')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
