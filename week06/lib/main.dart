import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'routes.dart';
import 'students_screen.dart';
import 'students.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    onGenerateRoute: (settings) {
      if (settings.name != Routes.student && settings.name != Routes.edit) {
        return null;
      }
      final student = settings.arguments as Student;
      if (settings.name == Routes.student) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailScreen(student: student),
        );
      }
      return MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => EditScreen(student: student),
      );
    },
  );
}
