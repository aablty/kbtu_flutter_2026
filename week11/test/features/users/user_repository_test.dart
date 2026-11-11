import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:students_api/core/api/api_client.dart';
import 'package:students_api/core/api/api_exception.dart';
import 'package:students_api/features/users/user_repository.dart';

import '../../fakes/memory_users_cache.dart';
import '../../fakes/test_secure_store.dart';

HttpUserRepository _repository(MockClient client) => HttpUserRepository(
  ApiClient(client, TestSecureStore()),
  MemoryUsersCache(),
);

final _wrongLatitudeUser = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': -37.3159, 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {
    'name': 'Romaguera-Crona',
    'catchPhrase': 'Multi-layered client-server neural-net',
  },
};

void main() {
  test('404 becomes NotFoundException', () {
    final repository = _repository(
      MockClient((_) async => http.Response('{"error":"gone"}', 404)),
    );

    expect(repository.getById(99), throwsA(isA<NotFoundException>()));
  });

  test('500 becomes ServerException', () {
    final repository = _repository(
      MockClient((_) async => http.Response('{}', 500)),
    );

    expect(repository.getById(99), throwsA(isA<ServerException>()));
  });

  test('SocketException becomes NoConnectionException', () {
    final repository = _repository(
      MockClient((_) async => throw const SocketException('down')),
    );

    expect(repository.getById(99), throwsA(isA<NoConnectionException>()));
  });

  test('numeric latitude becomes a BadResponseException', () {
    final repository = _repository(
      MockClient(
        (_) async => http.Response(jsonEncode([_wrongLatitudeUser]), 200),
      ),
    );

    expect(
      repository.getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (error) => error.detail,
          'detail',
          'users: lat is not a String',
        ),
      ),
    );
  });
}
