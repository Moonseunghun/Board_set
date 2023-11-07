import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'board.dart';



class UpdatePostScreen extends StatefulWidget {
  final Post post;

  UpdatePostScreen({required this.post});

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState(post);
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final Post post;
  late TextEditingController titleController;
  late TextEditingController contentController;

  _UpdatePostScreenState(this.post);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: post.title);
    contentController = TextEditingController(text: post.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수정하기'),
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
                _updatePost(post.id, titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePost(String id, String title, String content) {
    FirestoreService().updatePost(id, title, content, null); // 이미지 업데이트는 이전 이미지를 그대로 사용하도록 null 전달
  }
}

