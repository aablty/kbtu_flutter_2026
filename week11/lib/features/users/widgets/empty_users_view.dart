import 'package:flutter/material.dart';

class EmptyUsersView extends StatelessWidget {
  const EmptyUsersView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No users found'));
}
