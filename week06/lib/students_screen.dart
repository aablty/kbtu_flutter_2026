import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  void tapStudent(BuildContext context, int i) {
    Navigator.of(context).pushNamed(Routes.student, arguments: students[i]);
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
