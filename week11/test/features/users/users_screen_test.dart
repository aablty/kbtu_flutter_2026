import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:students_api/core/api/api_exception.dart';
import 'package:students_api/features/users/user.dart';
import 'package:students_api/features/users/user_repository.dart';
import 'package:students_api/features/users/users_model.dart';
import 'package:students_api/features/users/users_result.dart';
import 'package:students_api/features/users/users_screen.dart';

class _RetryRepository implements UserRepository {
  _RetryRepository(this.completer);

  final Completer<UsersResult> completer;
  int calls = 0;

  @override
  Future<UsersResult> getAll() {
    calls++;
    if (calls == 1) return Future.error(const NoConnectionException());
    return completer.future;
  }

  @override
  Future<User> getById(int id) async => throw UnimplementedError();

  @override
  Future<User> create(User draft) async => throw UnimplementedError();
}

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    final completer = Completer<UsersResult>();
    final repository = _RetryRepository(completer);
    final model = UsersModel(repository);
    await model.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: model)],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(const UsersResult(items: [], fromCache: false));
    await tester.pump();
  });
}
