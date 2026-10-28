import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  void _cartPressed(BuildContext context) {
    Navigator.of(context).pushNamed('/cart');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final count = context.select<Cart, int>((cart) => cart.count);
    return Badge(
      alignment: AlignmentGeometry.topLeft,
      label: Text('$count'),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () => _cartPressed(context),
      ),
    );
  }
}
