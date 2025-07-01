import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const HomeScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> toggleLike(String postId, List likes) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(currentUserId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: PostSearchDelegate(),
            ),
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts available."));
          }

          final posts = snapshot.data!.docs;
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final postId = post.id;

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['userName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(data['content'] ?? ''),
                      if (data['imageUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.network(
                            data['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              (data['likes'] as List?)?.contains(currentUserId) == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () => toggleLike(postId, data['likes'] ?? []),
                          ),
                          Text("${(data['likes']?.length ?? 0)} Likes"),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommentsScreen(postId: postId),
                              ),
                            ),
                          ),
                          Text("${data['commentCount'] ?? 0} Comments"),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final content = data['content']?.toLowerCase() ?? '';
          final author = data['userName']?.toLowerCase() ?? '';
          return content.contains(query.toLowerCase()) || author.contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final post = results[index];
            final data = post.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['userName'] ?? ''),
              subtitle: Text(data['content'] ?? ''),
              onTap: () => close(context, null),
            );
          },
        );
      },
    );
  }
}
