import 'package:flutter/material.dart';

import 'user.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_tile.dart';

class UserList extends StatelessWidget {
  const UserList({required this.users, this.fromCache = false, super.key});

  final List<User> users;
  final bool fromCache;

  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: users.length + (fromCache ? 1 : 0),
    separatorBuilder: (_, _) => const Divider(height: 1),
    itemBuilder: (context, index) {
      if (fromCache && index == 0) {
        return const OfflineBanner();
      }
      final userIndex = fromCache ? index - 1 : index;
      final user = users[userIndex];
      return UserTile(user: user);
    },
  );
}
