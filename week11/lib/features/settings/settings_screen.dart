import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>();
    final cities = users.items.map((user) => user.address.city).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) => unawaited(settings.setDark(value)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: settings.city,
            decoration: const InputDecoration(
              labelText: 'Filter city',
              border: OutlineInputBorder(),
            ),
            hint: const Text('All cities'),
            items: cities
                .map(
                  (city) =>
                      DropdownMenuItem<String>(value: city, child: Text(city)),
                )
                .toList(),
            onChanged: (value) => unawaited(settings.setCity(value)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: settings.city == null
                ? null
                : () => unawaited(settings.setCity(null)),
            child: const Text('Show all cities'),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => unawaited(context.read<AuthModel>().logout()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile photo'),
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.of(context).pushNamed('/about'),
          ),
          if (kDebugMode)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.developer_mode),
              title: const Text('Developer: API host'),
              subtitle: Text(settings.apiHost),
              onTap: () => _editHost(context, settings),
            ),
        ],
      ),
    );
  }

  Future<void> _editHost(BuildContext context, SettingsModel settings) async {
    final controller = TextEditingController(text: settings.apiHost);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer: API host'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || value == null) return;
    await settings.setApiHost(value);
  }
}
