import 'package:flutter/material.dart';

import 'students_future_screen.dart';
import 'students_screen.dart';
import 'countdown_screen.dart';

void main() => runApp(const StudentsAsyncApp());

class StudentsAsyncApp extends StatelessWidget {
  const StudentsAsyncApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Students Async',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    home: const HomeScreen(),
    routes: {
      '/by-hand': (_) => const StudentsScreen(),
      '/future': (_) => const StudentsFutureScreen(),
      '/countdown': (_) => const CountdownScreen(),
    },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Students Async')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/by-hand'),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/future'),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/countdown'),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    ),
  );
}
