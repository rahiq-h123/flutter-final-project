import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final commentData = {
      'authorId': user!.uid,
      'authorName': user.displayName ?? user.email,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    final commentsRef = postRef.collection('comments');

    await commentsRef.add(commentData);
    await postRef.update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
  }

  Stream<QuerySnapshot> _getCommentsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCommentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(comment['authorName'] ?? ''),
                      subtitle: Text(comment['content'] ?? ''),
                      trailing: Text(
                        (comment['timestamp'] as Timestamp?)?.toDate().toLocal().toString().substring(0, 16) ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}