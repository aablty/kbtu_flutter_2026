import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:students_api/features/settings/settings_model.dart';
import 'package:students_api/features/users/fake_user_repository.dart';
import 'package:students_api/features/users/users_model.dart';
import 'package:students_api/features/users/users_screen.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    final model = UsersModel(
      FakeUserRepository(fail: true, delay: const Duration(milliseconds: 100)),
    );
    await model.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider(
            create: (_) => SettingsModel(SharedPreferencesAsync(), dark: false),
          ),
        ],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
