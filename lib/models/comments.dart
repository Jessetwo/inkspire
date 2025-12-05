import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId; // Added postId field
  final String content;
  final String author;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.author,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'content': content,
    'author': author,
    'timestamp': timestamp,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] ?? '',
    postId: json['postId'] ?? '',
    content: json['content'] ?? '',
    author: json['author'] ?? '',
    timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
