import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:traveljournal/models/user_profile.dart';
import 'package:traveljournal/screen/login_screen.dart';
import 'package:traveljournal/screen/profile_screen.dart';
import 'package:traveljournal/auth/auth_service.dart';
import 'package:traveljournal/services/profile_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userEmail;
  final AuthService authService;

  const CustomAppBar({
    super.key,
    required this.userEmail,
    required this.authService,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _profileService = ProfileService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          if (profile?.avatarUrl != null) {
            print('Loaded avatar URL: ${profile!.avatarUrl}');
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Widget _buildAvatar() {
    if (_profile?.avatarUrl == null) {
      return const Icon(Icons.person, size: 24, color: Colors.grey);
    }

    final imageUrl =
        '${_profile!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}';
    print('Loading avatar from URL: $imageUrl');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      maxWidthDiskCache: 300,
      maxHeightDiskCache: 300,
      memCacheWidth: 300,
      memCacheHeight: 300,
      cacheKey: imageUrl
          .split('?')
          .first, // Cache by base URL without timestamp
      imageBuilder: (context, imageProvider) =>
          CircleAvatar(backgroundImage: imageProvider, radius: 16),
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
      errorWidget: (context, url, error) {
        print('Error loading avatar: $error from URL: $url');
        return const Icon(Icons.person, size: 24, color: Colors.grey);
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      await widget.authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 68,
      toolbarHeight: kToolbarHeight + 24,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: GestureDetector(
          onTap: () => _navigateToProfile(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatar(),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Hi, ${_profile?.username ?? widget.userEmail.split('@')[0]}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _navigateToProfile(context);
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
