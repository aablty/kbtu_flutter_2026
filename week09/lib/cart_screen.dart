import 'package:flutter/material.dart';
import 'package:shop/models/book.dart';

class CartScreen extends StatelessWidget {
  final List<Book> items;
  final void Function(Book) onRemove;

  const CartScreen({super.key, required this.items, required this.onRemove});

  Widget _cartItemBuilder(BuildContext context, int index) {
    final book = items[index];

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => onRemove(book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: _cartItemBuilder,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: ${items.fold(0, (sum, b) => sum + b.price)}'),
          ),
        ],
      ),
    );
  }
}
