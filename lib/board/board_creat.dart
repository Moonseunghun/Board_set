import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'board.dart';



class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _createPost(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: Text('게시물 추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _createPost(String title, String content) {
    FirestoreService().createPost(title, content, null); // 이미지는 여기에서 업로드할 수 있도록 코드 추가
  }
}