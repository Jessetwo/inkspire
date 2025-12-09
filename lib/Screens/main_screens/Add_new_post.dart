import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inkspire/Screens/main_screens/stories.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inkspire/components/my_button.dart';
import 'package:inkspire/components/my_textfield.dart';
import 'package:inkspire/services/post_services.dart';

class AddNewPost extends StatefulWidget {
  const AddNewPost({super.key});

  @override
  State<AddNewPost> createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _postTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Request storage permission based on Android version
  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) {
      // iOS uses photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      // Android - check version
      if (await Permission.photos.isGranted) {
        return true;
      }

      // For Android 13+ (API 33+), use photos/mediaLibrary
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
        ].request();

        // If photos permission is not available (older Android), try storage
        if (statuses[Permission.photos]?.isDenied ?? false) {
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }

        return statuses[Permission.photos]?.isGranted ?? false;
      }

      return false;
    }
  }

  // Pick image from gallery or camera with permission handling
  Future<void> _pickImage() async {
    try {
      // Request permission
      bool hasPermission = await _requestStoragePermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gallery access denied')),
          );
          // Show dialog to open settings
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'This app needs access to your photos to select images. Please grant permission in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image selected')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected')));
        }
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException in image_picker: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    } catch (e) {
      debugPrint('General error in image_picker: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Upload post to Firebase
  Future<void> _uploadPost() async {
    if (_postTitleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and select an image'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Current user: ${user?.uid}, ${user?.email}');
      if (user == null) {
        throw Exception('User not logged in');
      }

      final postService = PostService();
      debugPrint('Starting post upload with image: ${_selectedImage!.path}');
      await postService.createPost(
        imageFile: _selectedImage!,
        title: _postTitleController.text.trim(),
        author: user.displayName ?? user.email ?? 'Anonymous',
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully')),
        );

        // Clear form and navigate to Stories page
        setState(() {
          _selectedImage = null;
          _postTitleController.clear();
          _descriptionController.clear();
        });

        debugPrint('Navigating to Stories page');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Stories()),
        );
      }
    } catch (e) {
      debugPrint('Error uploading post: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Post',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E90FF),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 45),
          child: SingleChildScrollView(
            child: Column(
              children: [
                MyTextfield(
                  icon: Icons.post_add,
                  hint: 'Enter Post title',
                  controller: _postTitleController,
                ),
                const SizedBox(height: 16),
                MyTextfield(
                  hint: 'Enter Post Content',
                  maxLines: 10,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.8, color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                textAlign: TextAlign.center,
                                'Add A Cover Image',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Upload a high quality image to make your post stand out.',
                                  style: TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                alignment: Alignment.center,
                                width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Upload Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 54),
                MyButton(
                  title: _isUploading ? 'Uploading...' : 'Share Story',
                  onTap: _isUploading ? null : _uploadPost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
