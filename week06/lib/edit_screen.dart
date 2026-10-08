import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  final Student student;

  const EditScreen({super.key, required this.student});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;

  void _save() => Navigator.of(context).pop(_name);

  bool get _dirty => _name != widget.student.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit student')),
      body: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;

          final discard = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Discard changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          if (discard == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _name = v),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
