import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:widget_anonymous/main.dart';

void main() {
  testWidgets('app launches on the Sessions tab with seed data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Widget Anonymous'), findsOneWidget);
    expect(
      find.text('RenderFlex Overflowed by 42 Pixels: A Memoir'),
      findsOneWidget,
    );
  });

  testWidgets('search narrows the session list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Steve');
    await tester.pumpAndSettle();

    expect(
      find.text('My Memory Leak Has a Name and I Call Him Steve'),
      findsOneWidget,
    );
    expect(
      find.text('RenderFlex Overflowed by 42 Pixels: A Memoir'),
      findsNothing,
    );
  });

  testWidgets('opening a session shows its detail screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('RenderFlex Overflowed by 42 Pixels: A Memoir'));
    await tester.pumpAndSettle();

    expect(find.text('Overflow'), findsOneWidget);
    expect(find.textContaining('Join'), findsOneWidget);
  });

  testWidgets('joining without a profile name prompts to go to profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("I Still Don't Know What a BuildContext Is"));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Join (2/18)'));
    await tester.pumpAndSettle();

    expect(find.text('Set your name in Profile to join.'), findsOneWidget);

    await tester.tap(find.text('Go to profile'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);
  });

  testWidgets('saving the profile name lets you join a session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Aqtan');
    await tester.tap(find.widgetWithText(FilledButton, 'Save profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.forum_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I Still Don't Know What a BuildContext Is"));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Join (2/18)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Leave'), findsOneWidget);
  });

  testWidgets('creating a session requires a 3-60 character title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Hi');
    final saveButton = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Title must be 3-60 characters'), findsOneWidget);
  });

  testWidgets('backing out of a dirty new-session form asks to discard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'A new confession',
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });
}
