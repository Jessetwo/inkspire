import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkspire/models/user_model.dart';
import 'package:inkspire/services/auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = await _authService.getUserModel(user.uid);
      setState(() {
        _userModel = userModel;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeProfilePicture() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return; // User cancelled

      setState(() {
        _isUploadingPicture = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image and get URL
        final pictureUrl = await _authService.uploadProfilePicture(
          File(image.path),
          user.uid,
        );

        // Reload user data to get updated profile picture
        await _loadUserData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploadingPicture = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (context.mounted) {
        // Navigate to login screen - adjust route name as needed
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff1E90FF),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 45),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Picture with loading overlay
                  Stack(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xff1E90FF),
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _userModel?.profilePicture != null
                              ? Image.network(
                                  _userModel!.profilePicture!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/user.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/user.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      if (_isUploadingPicture)
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black54,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Change Profile Picture Button
                  GestureDetector(
                    onTap: _isUploadingPicture ? null : _changeProfilePicture,
                    child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isUploadingPicture
                            ? Colors.grey
                            : const Color(0xff1E90FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // User Information Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xff1E90FF).withOpacity(.1),
                    ),
                    child: Column(
                      children: [
                        // First name row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'First Name:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1E90FF),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _userModel?.firstname ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff1E90FF),
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Other name row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Other Name:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1E90FF),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _userModel?.othername ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff1E90FF),
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Email row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Email address:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1E90FF),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _userModel?.email ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff1E90FF),
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleLogout();
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
