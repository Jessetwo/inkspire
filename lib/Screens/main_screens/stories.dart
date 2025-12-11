import 'package:flutter/material.dart';
import 'package:inkspire/Screens/main_screens/post_details.dart';
import 'package:inkspire/components/my_textfield.dart';
import 'package:inkspire/firebase_image.dart';
import 'package:inkspire/models/post_model.dart';
import 'package:inkspire/services/post_services.dart';
import 'package:timeago/timeago.dart' as timeago;

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Post>> _postsFuture;
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _postsFuture = postService.getPosts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterPosts();
    });
  }

  void _filterPosts() {
    if (_searchQuery.isEmpty) {
      _filteredPosts = _allPosts;
    } else {
      _filteredPosts = _allPosts.where((post) {
        final titleMatch = post.title.toLowerCase().contains(_searchQuery);
        final descriptionMatch = post.description.toLowerCase().contains(
          _searchQuery,
        );
        final authorName =
            (post.authorFirstname.isNotEmpty && post.authorOthername.isNotEmpty)
            ? '${post.authorFirstname} ${post.authorOthername}'.toLowerCase()
            : post.author.toLowerCase();
        final authorMatch = authorName.contains(_searchQuery);

        return titleMatch || descriptionMatch || authorMatch;
      }).toList();
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = postService.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff1E90FF),
        title: Text(
          'Latest Stories',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              MyTextfield(
                hint: 'Search Stories',
                controller: _searchController,
                icon: Icons.search,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: FutureBuilder<List<Post>>(
                    future: _postsFuture,
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
                                onPressed: _refreshPosts,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No posts available')),
                          ],
                        );
                      }

                      // Update posts when data is loaded
                      _allPosts = snapshot.data!;
                      if (_searchQuery.isEmpty) {
                        _filteredPosts = _allPosts;
                      } else {
                        _filterPosts();
                      }

                      // Show filtered results
                      final postsToShow = _filteredPosts;

                      if (postsToShow.isEmpty && _searchQuery.isNotEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 200),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results found for "$_searchQuery"',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: postsToShow.length,
                        itemBuilder: (context, index) {
                          final post = postsToShow[index];

                          // Get author name from post
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
                                  height: 300,
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
                                    Text(
                                      '${timeago.format(post.timestamp)}  |',
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
