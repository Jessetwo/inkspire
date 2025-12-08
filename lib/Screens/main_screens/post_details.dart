import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inkspire/components/my_button.dart';
import 'package:inkspire/components/my_textfield.dart';
import 'package:inkspire/firebase_image.dart';
import 'package:inkspire/models/comments.dart';
import 'package:inkspire/models/post_model.dart';
import 'package:inkspire/services/post_services.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetails extends StatelessWidget {
  final Post post;
  final TextEditingController _commentController = TextEditingController();

  PostDetails({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();
    final user = FirebaseAuth.instance.currentUser;

    // Updated to use authorFirstname and authorOthername
    final authorName =
        (post.authorFirstname.isNotEmpty && post.authorOthername.isNotEmpty)
        ? '${post.authorFirstname} ${post.authorOthername}'
        : (post.author.isNotEmpty ? post.author : 'Anonymous');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postService.incrementViewCount(post.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story Details',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E90FF),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FirebaseImage(
                  storagePath: post.imagePath,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  'By $authorName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Text(post.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  'Comments',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Comment>>(
                  stream: postService.getCommentsStream(post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading comments'),
                      );
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(Icons.person, size: 24),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    comment.author,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                comment.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(comment.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Post Comment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                MyTextfield(
                  icon: Icons.comment,
                  hint: 'Write a comment',
                  controller: _commentController,
                ),
                const SizedBox(height: 10),
                MyButton(
                  title: 'Post Comment',
                  onTap: () async {
                    if (_commentController.text.trim().isNotEmpty) {
                      try {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to comment'),
                            ),
                          );
                          return;
                        }

                        // Fetch user's name from Firestore
                        String authorName = user.email ?? 'Anonymous';
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        if (userDoc.exists) {
                          final firstname =
                              userDoc.data()?['firstname']?.toString() ?? '';
                          final othername =
                              userDoc.data()?['othername']?.toString() ?? '';
                          if (firstname.isNotEmpty && othername.isNotEmpty) {
                            authorName = '$firstname $othername';
                          }
                        }

                        await postService.addComment(
                          postId: post.id,
                          content: _commentController.text,
                          author: authorName,
                        );
                        _commentController.clear();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment posted')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error posting comment: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
