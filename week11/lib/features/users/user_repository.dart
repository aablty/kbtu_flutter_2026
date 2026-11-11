import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

class UserRepository {
  UserRepository(this._api, [UsersCache? cache])
    : _cache = cache ?? UsersCache();

  final ApiClient _api;
  final UsersCache _cache;

  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final response = await _api.get(_api.uri('/users'));
      final decoded = _api.decode(response);
      final list = tryDecodeList(decoded);
      await _cache.save(list);
      return (items: list, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  List<User> tryDecodeList(dynamic decoded) {
    try {
      final list = decoded as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw BadResponseException('users: $error');
    }
  }

  Future<User> getById(int id) async {
    final response = await _api.get(_api.uri('/users/$id'));
    final decoded = _api.decode(response);
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } catch (error) {
      throw BadResponseException('users/$id: $error');
    }
  }

  Future<User> create(User draft) async {
    final response = await _api.post(
      _api.uri('/users'),
      jsonEncode(draft.toJson()),
    );
    if (response.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${response.statusCode}',
      );
    }

    final decoded = _api.decode(response);
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } catch (error) {
      throw BadResponseException('POST users: $error');
    }
  }
}
