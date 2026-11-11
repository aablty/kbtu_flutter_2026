import 'package:flutter/material.dart';

import 'user.dart';
import 'user_detail_screen.dart';

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
        return Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.secondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Text('Saved data · no connection · Retry'),
        );
      }
      final userIndex = fromCache ? index - 1 : index;
      final user = users[userIndex];
      return ListTile(
        title: Text(user.name),
        subtitle: Text('${user.email} · ${user.address.city}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: user)),
        ),
      );
    },
  );
}
