import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Consumer<Cart>(
        builder: (context, cart, _) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final book = cart.items[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => cart.remove(book),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Total: ${cart.total}'),
            ),
          ],
        ),
      ),
    );
  }
}
