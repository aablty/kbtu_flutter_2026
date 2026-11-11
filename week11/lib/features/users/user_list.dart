import 'package:flutter/material.dart';

import 'user.dart';
import 'user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList({required this.users, super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: users.length,
    separatorBuilder: (_, _) => const Divider(height: 1),
    itemBuilder: (context, index) {
      final user = users[index];
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
