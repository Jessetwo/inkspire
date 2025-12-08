import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:inkspire/models/post_model.dart';
import 'package:inkspire/models/comments.dart';

class PostService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final String _postsCollection = 'posts';
  final String _usersCollection = 'users';

  Future<Post> createPost({
    required File imageFile,
    required String title,
    required String author,
    required String description,
  }) async {
    try {
      debugPrint('Starting post creation: title=$title, author=$author');
      final user = FirebaseAuth.instance.currentUser;
      String authorFirstname = '';
      String authorOthername = '';

      if (user != null) {
        debugPrint('Current user UID: ${user.uid}');
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .get();

        debugPrint('User document exists: ${userDoc.exists}');

        if (userDoc.exists) {
          final userData = userDoc.data();
          debugPrint('User document data: $userData');

          authorFirstname = userDoc.data()?['firstname']?.toString() ?? '';
          authorOthername = userDoc.data()?['othername']?.toString() ?? '';

          debugPrint(
            'Extracted names: authorFirstname="$authorFirstname", authorOthername="$authorOthername"',
          );
        } else {
          debugPrint('No user document found for UID: ${user.uid}');
        }
      } else {
        debugPrint('No user logged in');
      }

      final imagePath = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      debugPrint('Uploading image to: $imagePath');
      final ref = _storage.ref().child(imagePath);
      debugPrint('Starting upload to Firebase Storage');
      final uploadTask = ref.putFile(imageFile);
      debugPrint('Waiting for upload to complete');
      final snapshot = await uploadTask;
      debugPrint('Upload completed, state: ${snapshot.state}');
      debugPrint('Storage path: $imagePath');

      debugPrint('Saving post to Firestore');
      final post = Post(
        id: '',
        imagePath: imagePath,
        title: title,
        authorFirstname: authorFirstname,
        authorOthername: authorOthername,
        author: author,
        timestamp: DateTime.now(),
        viewCount: 0,
        description: description,
      );

      debugPrint(
        'Post object created with: authorFirstname="$authorFirstname", authorOthername="$authorOthername"',
      );
      debugPrint('Post JSON: ${post.toJson()}');

      final docRef = await _firestore
          .collection(_postsCollection)
          .add(post.toJson());
      final newPost = Post(
        id: docRef.id,
        imagePath: post.imagePath,
        title: post.title,
        authorFirstname: post.authorFirstname,
        authorOthername: post.authorOthername,
        author: post.author,
        timestamp: post.timestamp,
        viewCount: post.viewCount,
        description: post.description,
      );
      await docRef.set(newPost.toJson());
      debugPrint('Post saved with ID: ${docRef.id}');
      return newPost;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPosts() async {
    try {
      debugPrint('Fetching posts from Firestore');
      final snapshot = await _firestore
          .collection(_postsCollection)
          .orderBy('timestamp', descending: true) // Sort by newest first
          .get();
      debugPrint('Found ${snapshot.docs.length} documents in Firestore');

      final posts = snapshot.docs
          .map((doc) {
            try {
              debugPrint('Parsing document ${doc.id}');
              final post = Post.fromJson(doc.data());
              debugPrint('Successfully parsed document ${doc.id}');
              return post;
            } catch (e) {
              debugPrint('Error parsing document ${doc.id}: $e');
              debugPrint('Document data: ${doc.data()}');
              return null;
            }
          })
          .where((post) => post != null)
          .cast<Post>()
          .toList();
      debugPrint(
        'Successfully fetched ${posts.length} posts out of ${snapshot.docs.length} documents',
      );
      return posts;
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> incrementViewCount(String postId) async {
    try {
      debugPrint('Incrementing view count for post: $postId');
      final docRef = _firestore.collection(_postsCollection).doc(postId);
      await docRef.update({'viewCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
      rethrow;
    }
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    try {
      debugPrint('Fetching comments for post: $postId');
      return _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection('comments')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) {
                  try {
                    return Comment.fromJson(doc.data());
                  } catch (e) {
                    debugPrint(
                      'Error parsing comment for post $postId: $e, Data: ${doc.data()}',
                    );
                    return null;
                  }
                })
                .where((comment) => comment != null)
                .cast<Comment>()
                .toList(),
          );
    } catch (e) {
      debugPrint('Error streaming comments: $e');
      rethrow;
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String author,
  }) async {
    try {
      debugPrint('Adding comment for post: $postId, author: $author');
      final user = FirebaseAuth.instance.currentUser;
      String commentAuthor = author;
      if (user != null) {
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final firstname = userDoc.data()?['firstname']?.toString() ?? '';
          final othername = userDoc.data()?['othername']?.toString() ?? '';
          if (firstname.isNotEmpty && othername.isNotEmpty) {
            commentAuthor = '$firstname $othername';
          }
        } else {
          debugPrint('No user document found for UID: ${user.uid}');
        }
      }
      final comment = Comment(
        id: '',
        postId: postId,
        content: content,
        author: commentAuthor,
        timestamp: DateTime.now(),
      );
      final docRef = _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection('comments')
          .doc();
      final newComment = Comment(
        id: docRef.id,
        postId: comment.postId,
        content: comment.content,
        author: comment.author,
        timestamp: comment.timestamp,
      );
      await docRef.set(newComment.toJson());
      debugPrint('Comment added with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }
}
