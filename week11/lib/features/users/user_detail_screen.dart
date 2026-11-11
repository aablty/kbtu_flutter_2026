import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
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
        _LinkTile(
          label: 'Email',
          value: user.email,
          uri: Uri(scheme: 'mailto', path: user.email),
        ),
        _LinkTile(
          label: 'Phone',
          value: user.phone,
          uri: Uri(scheme: 'tel', path: user.phoneDigits),
        ),
        _ValueTile(label: 'Phone digits', value: user.phoneDigits),
        if (user.website case final website?)
          _LinkTile(
            label: 'Website',
            value: website,
            uri: Uri.parse('https://$website'),
          )
        else
          const _ValueTile(label: 'Website', value: '—'),
        if (kDebugMode)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.key),
            title: const Text('Copy token to clipboard'),
            onTap: () async {
              final token = await context.read<AuthModel>().readTokenForDebug();
              if (!context.mounted || token == null) return;
              await Clipboard.setData(ClipboardData(text: token));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Token copied')));
            },
          ),
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

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.label,
    required this.value,
    required this.uri,
  });

  final String label;
  final String value;
  final Uri uri;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: Theme.of(context).textTheme.labelLarge),
    subtitle: Text(value),
    trailing: const Icon(Icons.open_in_new),
    onTap: () => unawaited(_openLink(context, uri)),
  );
}

Future<void> _openLink(BuildContext context, Uri uri) async {
  final opened = await launchUrl(uri);
  if (!context.mounted || opened) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('No app can open this')));
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
