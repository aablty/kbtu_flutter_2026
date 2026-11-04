import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _save() async {
    if (_saving || _students == null) return;
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = switch ((_error, _students)) {
      (_?, _) => ErrorView(onRetry: () => unawaited(_load())),
      (_, null) => const LoadingView(),
      (_, final students?) when students.isEmpty => const EmptyView(),
      (_, final students?) => StudentList(students: students),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: body,
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              onPressed: _saving ? null : _save,
              tooltip: 'Save',
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
