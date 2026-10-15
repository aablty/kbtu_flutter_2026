import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

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

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (context) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        break;
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
        break;
      case BookAction.delete:
        setState(() => _books.remove(book));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _statColumn(
                        textTheme,
                        '${_books.length}',
                        'Books',
                      ),
                    ),
                    Expanded(
                      child: _statColumn(
                        textTheme,
                        '${totalPages(_books)}',
                        'Pages',
                      ),
                    ),
                    Expanded(
                      child: _statColumn(
                        textTheme,
                        '${unread(_books).length}',
                        'Unread',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                return InkWell(
                  onTap: () => _openDetail(book),
                  child: BookTile(
                    book: book,
                    onToggle: () => setState(() => book.read = !book.read),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statColumn(TextTheme textTheme, String value, String label) => Column(
  children: [
    Text(value, style: textTheme.headlineSmall),
    Text(label, style: textTheme.bodySmall),
  ],
);
