import 'package:flutter/material.dart';

import 'models/book.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Reading list (${_visible.length})')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == Filter.all,
                onSelected: (_) => setState(() => _filter = Filter.all),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unread'),
                selected: _filter == Filter.unread,
                onSelected: (_) => setState(() => _filter = Filter.unread),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Read'),
                selected: _filter == Filter.read,
                onSelected: (_) => setState(() => _filter = Filter.read),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _visible.length,
            itemBuilder: (context, index) {
              final book = _visible[index];
              return CheckboxListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                value: book.read,
                onChanged: (v) => setState(() => book.read = v ?? false),
              );
            },
          ),
        ),
      ],
    ),
  );
}
