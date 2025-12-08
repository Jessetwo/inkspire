import 'package:flutter/material.dart';
import 'package:inkspire/Screens/main_screens/post_details.dart';
import 'package:inkspire/firebase_image.dart';
import 'package:inkspire/models/post_model.dart';
import 'package:inkspire/services/post_services.dart';
import 'package:timeago/timeago.dart' as timeago;

class Stories extends StatelessWidget {
  const Stories({super.key});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Latest Stories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Post>>(
                  future: postService.getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('Error in FutureBuilder: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading posts: ${snapshot.error}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Stories(),
                                  ),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts available'));
                    }

                    final posts = snapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        // Get author name from post's authorFirstname and authorOthername fields
                        final authorName =
                            (post.authorFirstname.isNotEmpty &&
                                post.authorOthername.isNotEmpty)
                            ? '${post.authorFirstname} ${post.authorOthername}'
                            : (post.author.isNotEmpty
                                  ? post.author
                                  : 'Anonymous');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetails(post: post),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FirebaseImage(
                                storagePath: post.imagePath,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text('$authorName  |'),
                                  const SizedBox(width: 5),
                                  Text('${timeago.format(post.timestamp)}  |'),
                                  const SizedBox(width: 5),
                                  Text('${post.viewCount} views'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.description,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
