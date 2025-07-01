import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userEmail;
  final String content;
  final String? imageUrl;
  final Timestamp timestamp;
  final List<String> likes;

  Post({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likes,
  });

  factory Post.fromMap(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
