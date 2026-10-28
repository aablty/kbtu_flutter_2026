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
                  final quantity = cart.qtyOf(book);
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text('${book.author} ×$quantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cart.increment(book),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => cart.remove(book),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Consumer<Cart>(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.shopping_bag), Text(' Total')],
              ),
              builder: (context, cart, child) => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [child!, Text(': ${cart.total}')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
