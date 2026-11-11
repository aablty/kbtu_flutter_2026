import 'user.dart';

class UsersResult {
  const UsersResult({required this.items, required this.fromCache});

  final List<User> items;
  final bool fromCache;
}
