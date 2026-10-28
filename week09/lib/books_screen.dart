import 'package:flutter/material.dart';
import 'package:shop/cart_badge.dart';

import 'models/book.dart';

class BooksScreen extends StatelessWidget {
  final List<Book> cart;
  final int total;
  final void Function(Book) onAdd;

  const BooksScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
  });

  Widget _bookItemBuilder(BuildContext context, int index) {
    final book = books[index];
    debugPrint('row ${book.title}');
    final inCart = cart.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => onAdd(book),
              child: const Text('Add'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [CartBadge(count: cart.length, total: total)],
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: _bookItemBuilder,
      ),
    );
  }
}
