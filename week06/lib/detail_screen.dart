import 'package:flutter/material.dart';

import 'students.dart';

class DetailScreen extends StatelessWidget {
  final Student student;

  const DetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: Column(
        children: [
          ListTile(leading: Icon(Icons.school), title: Text(student.group)),
          ListTile(leading: Icon(Icons.mail), title: Text(student.email)),
        ],
      ),
    );
  }
}
