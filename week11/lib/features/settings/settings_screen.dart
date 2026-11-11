import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        ],
      ),
    );
  }
}
