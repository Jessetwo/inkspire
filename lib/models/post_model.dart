import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imagePath;
  final String title;
  final String firstname; // Changed from firstName
  final String othername; // Changed from lastName
  final String author;
  final DateTime timestamp;
  final int viewCount;
  final String description;

  Post({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.firstname,
    required this.othername,
    required this.author,
    required this.timestamp,
    required this.viewCount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'title': title,
    'firstname': firstname, // Changed
    'othername': othername, // Changed
    'author': author,
    'timestamp': Timestamp.fromDate(timestamp),
    'viewCount': viewCount,
    'description': description,
  };

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parsedTimestamp;
      if (json['timestamp'] is Timestamp) {
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is String) {
        parsedTimestamp =
            DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now();
      } else {
        parsedTimestamp = DateTime.now();
      }
      return Post(
        id: json['id'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        title: json['title'] as String? ?? '',
        firstname:
            json['firstname'] as String? ??
            json['firstName'] as String? ??
            '', // Handle old posts
        othername:
            json['othername'] as String? ??
            json['lastName'] as String? ??
            '', // Handle old posts
        author: json['author'] as String? ?? 'Anonymous',
        timestamp: parsedTimestamp,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        description: json['description'] as String? ?? '',
      );
    } catch (e) {
      print('Error parsing Post from JSON: $e, JSON: $json');
      rethrow;
    }
  }
}
