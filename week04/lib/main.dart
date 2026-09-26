import 'package:flutter/material.dart';

import 'stopwatch_card.dart';
import 'tap_card.dart';
import 'two_way_counter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  static const neutral700 = Color(0xFF404040);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: neutral700)
          .copyWith(primary: neutral700),
    ),
    debugShowCheckedModeBanner: false,
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A screen that reacts - Tashimov O_O')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TapCard(),
          SizedBox(height: 16),
          TwoWayCounter(),
          SizedBox(height: 16),
          StopwatchCard(),
        ],
      ),
    );
  }
}
