import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  final Book book;

  const DetailScreen({super.key, required this.book});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      Navigator.pop(context, BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final yearText = book.year == null ? 'Year unknown' : '${book.year}';

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(book.author, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${book.pages} pp.'),
            Text(yearText),
            Text(book.read ? 'Read' : 'Unread'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context, BookAction.toggleRead),
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _delete(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
