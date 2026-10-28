import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/cart_badge.dart';

import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return books;
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query),
        )
        .toList();
  }

  Widget _bookItemBuilder(BuildContext context, int index) {
    final book = _visibleBooks[index];
    debugPrint('row ${book.title}');
    final inCart = context.watch<Cart>().items.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visibleBooks = _visibleBooks;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView.builder(
        itemCount: visibleBooks.length,
        itemBuilder: _bookItemBuilder,
      ),
    );
  }
}
