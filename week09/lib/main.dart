import 'package:flutter/material.dart';

import 'models/book.dart';
import 'models/cart.dart';
import 'books_screen.dart';
import 'cart_screen.dart';

void main() {
  final cart = Cart();
  cart.add(books[0]);
  cart.add(books[1]);
  cart.add(books[0]);
  cart.remove(books[0]);
  debugPrint('${cart.count} items, ${cart.total} ₸');
  runApp(const Shell());
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];

  void _add(Book b) => setState(() => _cart.add(b));

  void _remove(Book b) => setState(() => _cart.remove(b));

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    routes: {
      '/': (_) => BooksScreen(
        cart: _cart,
        total: _cart.fold(0, (sum, book) => sum + book.price),
        onAdd: _add,
      ),
      '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
    },
  );
}
