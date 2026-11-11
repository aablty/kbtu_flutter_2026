import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:students_api/core/api/api_client.dart';
import 'package:students_api/core/api/api_exception.dart';
import 'package:students_api/features/users/user.dart';
import 'package:students_api/features/users/user_repository.dart';

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

void main() {
  test('repository decodes a list without importing http', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode([_userJson(1)]), 200),
    );
    final repository = UserRepository(ApiClient(client));

    final users = await repository.getAll();

    expect(users.single.id, 1);
  });

  test('repository maps 404 to NotFoundException', () async {
    final client = MockClient((_) async => http.Response('{}', 404));
    final repository = UserRepository(ApiClient(client));

    expect(repository.getById(999), throwsA(isA<NotFoundException>()));
  });

  test('repository creates a user from a 201 response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.headers['content-type'], 'application/json');
      return http.Response(jsonEncode(_userJson(11)), 201);
    });
    final repository = UserRepository(ApiClient(client));
    final draft = User.fromJson(_userJson(1));

    final created = await repository.create(draft);

    expect(created.id, 11);
  });
}
