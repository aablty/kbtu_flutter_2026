import 'package:flutter/material.dart';

import 'profile.dart';
import 'session.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.sessions,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final ValueChanged<Profile> onProfileChanged;
  final List<Session> sessions;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _groupController = TextEditingController(
    text: widget.profile.group,
  );

  static final _groupPattern = RegExp(r'^[A-Za-z]{2}-\d{4}$');

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _nameController.text = widget.profile.name;
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onProfileChanged(
      Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listCount = widget.sessions
        .where((session) => session.contains(widget.profile.name))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _groupController,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'e.g. SE-2103',
              ),
              textInputAction: TextInputAction.done,
              validator: (value) {
                final group = (value ?? '').trim();
                if (group.isEmpty) return null;
                return _groupPattern.hasMatch(group)
                    ? null
                    : 'Use the format AB-1234';
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save profile')),
            const SizedBox(height: 24),
            Text(
              'You are on $listCount list${listCount == 1 ? '' : 's'}.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('System'),
                  selected: widget.themeMode == ThemeMode.system,
                  onSelected: (_) =>
                      widget.onThemeModeChanged(ThemeMode.system),
                ),
                ChoiceChip(
                  label: const Text('Light'),
                  selected: widget.themeMode == ThemeMode.light,
                  onSelected: (_) => widget.onThemeModeChanged(ThemeMode.light),
                ),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: widget.themeMode == ThemeMode.dark,
                  onSelected: (_) => widget.onThemeModeChanged(ThemeMode.dark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
