import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  final _authorFocus = FocusNode();
  final _pagesFocus = FocusNode();
  final _yearFocus = FocusNode();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    for (final f in [_authorFocus, _pagesFocus, _yearFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text),
      year: int.tryParse(_year.text),
    );
    Navigator.pop(context, book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(label: Text('Title')),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _authorFocus.requestFocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) => (v ?? '').trim().length < 2
                  ? 'Title must be at least 2 characters'
                  : null,
            ),
            TextFormField(
              controller: _author,
              focusNode: _authorFocus,
              decoration: const InputDecoration(label: Text('Author')),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _pagesFocus.requestFocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Author is required' : null,
            ),
            TextFormField(
              controller: _pages,
              focusNode: _pagesFocus,
              decoration: const InputDecoration(label: Text('Pages')),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _yearFocus.requestFocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'A whole number above 0';
                return null;
              },
            ),
            TextFormField(
              controller: _year,
              focusNode: _yearFocus,
              decoration: const InputDecoration(
                label: Text('Year'),
                hintText: 'Optional',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                final n = int.tryParse(v ?? '');
                final currentYear = DateTime.now().year;
                if (n == null || n < 1450 || n > currentYear) {
                  return 'Enter a year between 1450 and $currentYear';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    ),
  );
}
