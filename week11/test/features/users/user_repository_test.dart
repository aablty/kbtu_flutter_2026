import 'dart:io';

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
}
