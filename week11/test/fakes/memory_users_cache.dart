import 'package:students_api/features/users/user.dart';
import 'package:students_api/features/users/users_cache.dart';

class MemoryUsersCache extends UsersCache {
  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;

  @override
  Future<List<User>?> load() async => saved;
}
