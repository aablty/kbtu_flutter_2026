import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  final int count;
  final int total;

  const CartBadge({super.key, required this.count, required this.total});

  void _cartPressed(BuildContext context) {
    Navigator.of(context).pushNamed('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      alignment: AlignmentGeometry.topLeft,
      label: Text('$count · $total'),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () => _cartPressed(context),
      ),
    );
  }
}
