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

  // Pick image from gallery or camera with permission handling
  Future<void> _pickImage() async {
    try {
      // Request gallery permission
      final status = await Permission.photos.request();
      if (status.isGranted) {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image selected')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected')));
        }
      } else {
        debugPrint('Permission denied for photos: $status');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gallery access denied')));
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException in image_picker: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied or app error: ${e.message}')),
      );
    } catch (e) {
      debugPrint('General error in image_picker: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
    } catch (e) {
      debugPrint('Error uploading post: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading post: $e')));
    } finally {
      setState(() => _isUploading = false);
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
                  hint: 'Enter post details',
                  maxLines: 6,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.8, color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload_file, size: 100),
                              SizedBox(height: 10),
                              Text('Upload a featured Image'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
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
