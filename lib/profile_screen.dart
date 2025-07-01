import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'comments_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _uploading = false;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Stream<QuerySnapshot> getUserPosts() {
    final uid = user!.uid;
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> pickAndUploadProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user!.uid}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await user!.updatePhotoURL(url);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated.')));
      setState(() {});
    } catch (e) {
      print("Upload Error: $e");
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey[400], 
                ),

                const SizedBox(height: 8),
                // Text("Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'No name'}"),
                Text("Email: ${user?.email}"),
                const SizedBox(height: 8),
                _uploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: pickAndUploadProfilePicture,
                        child: const Text("Upload Profile Picture"),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text("My Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getUserPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(child: Text("You haven't posted anything yet."));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['content'] ?? ''),
                            if (data['imageUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Image.network(data['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.cover),
                              ),
                            const SizedBox(height: 8),
                            Text("Likes: ${(data['likes']?.length ?? 0)}"),
                            Text("Comments: ${data['commentCount'] ?? 0}"),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(postId: post.id),
                                ),
                              ),
                              child: const Text("View Comments"),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}