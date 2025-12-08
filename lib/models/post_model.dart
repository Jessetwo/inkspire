import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String author;
  final String authorFirstname;
  final String authorOthername;
  final DateTime timestamp;
  final int viewCount;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.author,
    required this.authorFirstname,
    required this.authorOthername,
    required this.timestamp,
    required this.viewCount,
  });

  // Updated fromJson with better error handling
  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      // Handle timestamp conversion safely
      DateTime parsedTimestamp;
      if (json['timestamp'] is Timestamp) {
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is String) {
        parsedTimestamp = DateTime.parse(json['timestamp']);
      } else if (json['timestamp'] is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'],
        );
      } else {
        parsedTimestamp = DateTime.now();
      }

      return Post(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        imagePath: json['imagePath']?.toString() ?? '',
        author: json['author']?.toString() ?? '',
        authorFirstname: json['authorFirstname']?.toString() ?? '',
        authorOthername: json['authorOthername']?.toString() ?? '',
        timestamp: parsedTimestamp,
        viewCount: json['viewCount'] is int
            ? json['viewCount']
            : int.tryParse(json['viewCount']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      print('Error parsing Post from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'author': author,
      'authorFirstname': authorFirstname,
      'authorOthername': authorOthername,
      'timestamp': Timestamp.fromDate(timestamp),
      'viewCount': viewCount,
    };
  }
}
