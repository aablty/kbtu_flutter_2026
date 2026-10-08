import 'package:flutter/material.dart';

import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

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
        ),
      ),
    );
  }
}
