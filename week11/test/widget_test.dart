import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:students_api/core/api/api_client.dart';
import 'package:students_api/core/api/api_exception.dart';
import 'package:students_api/core/storage/secure_store.dart';
import 'package:students_api/features/users/user.dart';
import 'package:students_api/features/users/user_repository.dart';
import 'package:students_api/features/users/users_cache.dart';
import 'package:students_api/features/users/new_user_screen.dart';
import 'package:students_api/features/users/users_model.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> _userJson(int id) => {
  'id': id,
  'name': 'User $id',
  'username': 'user$id',
  'email': 'user$id@example.com',
  'address': {
    'street': 'Street',
    'suite': 'Suite',
    'city': 'City',
    'zipcode': '00000',
    'geo': {'lat': '1.0', 'lng': '2.0'},
  },
  'phone': '123',
  'website': null,
  'company': {'name': 'Company', 'catchPhrase': 'Phrase'},
};

class _NoTokenStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;
}

class _MemoryCache extends UsersCache {
  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;

  @override
  Future<List<User>?> load() async => saved;
}

void main() {
  test('repository decodes a list without importing http', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode([_userJson(1)]), 200),
    );
    final repository = HttpUserRepository(
      ApiClient(client, _NoTokenStore()),
      _MemoryCache(),
    );

    final result = await repository.getAll();

    expect(result.items.single.id, 1);
  });

  test('repository maps 404 to NotFoundException', () async {
    final client = MockClient((_) async => http.Response('{}', 404));
    final repository = HttpUserRepository(
      ApiClient(client, _NoTokenStore()),
      _MemoryCache(),
    );

    expect(repository.getById(999), throwsA(isA<NotFoundException>()));
  });

  test('repository creates a user from a 201 response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.headers['content-type'], 'application/json');
      return http.Response(jsonEncode(_userJson(11)), 201);
    });
    final repository = HttpUserRepository(
      ApiClient(client, _NoTokenStore()),
      _MemoryCache(),
    );
    final draft = User.fromJson(_userJson(1));

    final created = await repository.create(draft);

    expect(created.id, 11);
  });

  test('timeout becomes NoConnectionException', () async {
    final client = MockClient(
      (_) => Future<http.Response>.delayed(
        const Duration(seconds: 11),
        () => http.Response('[]', 200),
      ),
    );
    final repository = HttpUserRepository(
      ApiClient(client, _NoTokenStore()),
      _MemoryCache(),
    );

    expect(repository.getAll(), throwsA(isA<NoConnectionException>()));
  });

  testWidgets('new user form sends one POST and closes', (tester) async {
    var postCount = 0;
    final client = MockClient((request) async {
      postCount++;
      return http.Response(jsonEncode(_userJson(11)), 201);
    });
    final model = UsersModel(
      HttpUserRepository(ApiClient(client, _NoTokenStore()), _MemoryCache()),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: NewUserScreen()),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'New User');
    await tester.enterText(find.byType(TextFormField).at(1), 'newuser');
    await tester.enterText(find.byType(TextFormField).at(2), 'new@example.com');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(postCount, 1);
  });
}
