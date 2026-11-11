import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final response = await _api.get(_api.uri('/users'));
    final decoded = _api.decode(response);
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
