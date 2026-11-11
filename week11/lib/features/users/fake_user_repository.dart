import 'dart:async';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';
import 'users_result.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  static const _users = [
    User(
      id: 1,
      name: 'Aida Nurlanova',
      username: 'aida',
      email: 'aida@example.com',
      phone: '123',
      website: 'example.com',
      address: Address(
        street: 'Street',
        suite: 'Suite',
        city: 'Almaty',
        zipcode: '00000',
        geo: Geo(lat: 43.2389, lng: 76.8897),
      ),
      company: (name: 'KBTU', catchPhrase: 'Learn by building'),
    ),
    User(
      id: 2,
      name: 'Dias Seitkali',
      username: 'dias',
      email: 'dias@example.com',
      phone: '456',
      website: 'example.org',
      address: Address(
        street: 'Second street',
        suite: 'Suite',
        city: 'Astana',
        zipcode: '11111',
        geo: Geo(lat: 51.1694, lng: 71.4491),
      ),
      company: (name: 'KBTU', catchPhrase: 'Ship it'),
    ),
  ];

  @override
  Future<UsersResult> getAll() async {
    await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
    return const UsersResult(items: _users, fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    final result = _users.where((user) => user.id == id);
    if (result.isEmpty) throw const NotFoundException();
    return result.first;
  }

  @override
  Future<User> create(User draft) async => draft;
}
