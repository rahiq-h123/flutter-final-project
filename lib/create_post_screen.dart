import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('post_images').child(fileName);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _submitPost() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  await FirebaseAuth.instance.currentUser!.reload(); 
  final user = FirebaseAuth.instance.currentUser;
  final content = _contentController.text.trim();
  String? imageUrl;

  try {
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    final userName = (user!.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName
        : user.email; // ✅ fallback للإيميل

    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user.uid,
      'userName': userName,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'commentCount': 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post created successfully!")),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Content cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              _imageFile != null
                  ? Stack(
                      children: [
                        Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => setState(() => _imageFile = null),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Add Image"),
                    ),
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}