// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';

void main() {
  print('A');
  unawaited(Future<void>.delayed(const Duration(seconds: 2), () => print('B')));
  print('C');

  final api = FakeApi();
  unawaited(
    api.fetchStudents().then(
      (students) => print('${students.length} students'),
    ),
  );

  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Students Async'))),
    ),
  );
}
