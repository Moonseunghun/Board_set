import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../auth/login.dart';
import 'board_creat.dart';
import 'board_read.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;

  Post({required this.id, required this.title, required this.content, required this.imageUrl});
}

class FirestoreService {
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  Future<String> createPost(String title, String content, File? imageFile) async {
    String imageUrl = '';

    if (imageFile != null) {
      Reference ref = storage.ref().child('images/${DateTime.now().toString()}');
      UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });
    }

    DocumentReference docRef = await postsCollection.add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    });

    return docRef.id;
  }

  Stream<List<Post>> getPosts() {
    return postsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post(
          id: doc.id,
          title: doc['title'],
          content: doc['content'],
          imageUrl: doc['imageUrl'],
        );
      }).toList();
    });
  }

  Future<void> updatePost(String id, String title, String content, File? imageFile) async {
    String imageUrl = '';

    if (imageFile != null) {
      Reference ref = storage.ref().child('images/${DateTime.now().toString()}');
      UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });
    }

    await postsCollection.doc(id).update({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String id) async {
    await postsCollection.doc(id).delete();
  }
}

Future<void> _signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login screen or any other screen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } catch (e) {
    print('Error signing out: $e');
    // Handle error here
  }
}

class MyBoardApp extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('게시판'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _signOut(context);
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Post>>(
          stream: firestoreService.getPosts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              List<Post> posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(posts[index].title),
                    subtitle: Text(posts[index].content),
                    leading: posts[index].imageUrl.isNotEmpty ? Image.network(
                        posts[index].imageUrl) : null,
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        firestoreService.deletePost(posts[index].id);
                      },
                    ),
                    onTap: () {
                      _navigateToUpdateScreen(context, posts[index]);
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToCreateScreen(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

  void _navigateToUpdateScreen(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdatePostScreen(post: post)),
    );
  }

  void _navigateToCreateScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen()),
    );
  }

