import 'package:flutter/material.dart';

import 'students.dart';
import 'detail_screen.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  void tapStudent(BuildContext context, int i) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(student: students[i])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: CircleAvatar(child: Text(students[i].name[0])),
          title: Text(students[i].name),
          subtitle: Text(students[i].group),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => tapStudent(context, i),
        ),
      ),
    );
  }
}
