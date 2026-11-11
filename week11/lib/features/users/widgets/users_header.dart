import 'package:flutter/material.dart';

class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({
    required this.onCreate,
    required this.onSettings,
    super.key,
  });

  final VoidCallback onCreate;
  final VoidCallback onSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Users'),
    actions: [
      IconButton(
        onPressed: onCreate,
        icon: const Icon(Icons.person_add),
        tooltip: 'New user',
      ),
      IconButton(
        onPressed: onSettings,
        icon: const Icon(Icons.settings),
        tooltip: 'Settings',
      ),
    ],
  );
}
