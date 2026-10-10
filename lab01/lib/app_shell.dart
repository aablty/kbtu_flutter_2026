import 'package:flutter/material.dart';

import 'favourites_tab.dart';
import 'profile.dart';
import 'profile_tab.dart';
import 'routes.dart';
import 'session.dart';
import 'sessions_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<Session> _sessions = buildSeedSessions();
  Profile _profile = Profile.empty();
  int _tabIndex = 0;

  void _switchToTab(int index) => setState(() => _tabIndex = index);

  void _toggleFavourite(Session session) {
    setState(() {
      _sessions = [
        for (final s in _sessions)
          if (identical(s, session)) s.copyWith(favourite: !s.favourite) else s,
      ];
    });
  }

  void _replaceSession(Session original, Session updated) {
    setState(() {
      _sessions = [
        for (final s in _sessions)
          if (identical(s, original)) updated else s,
      ];
    });
  }

  void _deleteSession(Session target) {
    setState(() {
      _sessions = _sessions.where((s) => !identical(s, target)).toList();
    });
  }

  void _openDetail(Session session) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: SessionDetailArgs(
        session: session,
        profile: _profile,
        onUpdate: (updated) => _replaceSession(session, updated),
        onDelete: () => _deleteSession(session),
        onSwitchToProfileTab: () => _switchToTab(2),
      ),
    );
  }

  Future<void> _createSession() async {
    final result = await Navigator.of(context)
        .pushNamed<Session>(Routes.form, arguments: const SessionFormArgs());
    if (result == null || !mounted) return;
    setState(() => _sessions = [..._sessions, result]);
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'Sessions and your profile will go back to their defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _sessions = buildSeedSessions();
      _profile = Profile.empty();
    });
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About Widget Anonymous'),
        content: const Text(
          'A support group for Flutter developers to confess their worst '
          'bugs. Nobody judges here. Well, mostly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Anonymous')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Widget Anonymous')),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
              onTap: () {
                Navigator.pop(context);
                _confirmReset();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          SessionsTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          ProfileTab(
            profile: _profile,
            onProfileChanged: _setProfile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _createSession,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _switchToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
