import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Uri uri(String path, [Map<String, String>? queryParameters]) =>
      Uri.https(host, path, queryParameters);

  Future<http.Response> get(Uri uri) =>
      _send(() => _client.get(uri, headers: headers));

  Future<http.Response> post(Uri uri, String body) => _send(
    () => _client.post(
      uri,
      headers: {...headers, 'Content-Type': 'application/json'},
      body: body,
    ),
  );

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        developer.log(
          '${response.request?.method} '
          '${response.request?.url.path} -> ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  dynamic decode(http.Response response) {
    _check(response);
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw BadResponseException(error.message);
    }
  }

  void _check(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw const UnauthorizedException();
      case 404:
        throw const NotFoundException();
      default:
        if (response.statusCode >= 500) {
          throw ServerException(response.statusCode);
        }
    }
  }
}
