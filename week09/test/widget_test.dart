import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('lifted cart flows through both routes', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    await tester.tap(find.text('Add').first);
    await tester.pump();
    await tester.tap(find.text('Add').at(1));
    await tester.pump();

    expect(find.text('Added'), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    expect(find.text('Cart'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
  });
}
