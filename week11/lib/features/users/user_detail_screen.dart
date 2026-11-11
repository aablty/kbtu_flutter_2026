import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(user.name)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ValueTile(label: 'ID', value: '${user.id}'),
        _ValueTile(label: 'Username', value: user.username),
        _ValueTile(label: 'Email', value: user.email),
        _ValueTile(label: 'Phone', value: user.phone),
        _ValueTile(label: 'Phone digits', value: user.phoneDigits),
        _ValueTile(label: 'Website', value: user.website ?? '—'),
        _ValueTile(label: 'Street', value: user.address.street),
        _ValueTile(label: 'Suite', value: user.address.suite),
        _ValueTile(label: 'City', value: user.address.city),
        _ValueTile(label: 'Zipcode', value: user.address.zipcode),
        _ValueTile(
          label: 'Coordinates',
          value: '${user.address.geo.lat}, ${user.address.geo.lng}',
        ),
        _ValueTile(label: 'Company', value: user.company.name),
        _ValueTile(label: 'Company phrase', value: user.company.catchPhrase),
      ],
    ),
  );
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: Theme.of(context).textTheme.labelLarge),
    subtitle: Text(value),
  );
}
