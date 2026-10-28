import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/cart_badge.dart';

import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  Widget _bookItemBuilder(BuildContext context, int index) {
    final book = books[index];
    debugPrint('row ${book.title}');
    final inCart = context.watch<Cart>().items.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => context.read<Cart>().add(book),
              child: const Text('Add'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: _bookItemBuilder,
      ),
    );
  }
}
