import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'routes.dart';
import 'session.dart';
import 'session_detail_screen.dart';
import 'session_form_screen.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Widget Anonymous',
    theme: buildLightTheme(),
    darkTheme: buildDarkTheme(),
    themeMode: _themeMode,
    initialRoute: Routes.shell,
    routes: {
      Routes.shell: (_) =>
          AppShell(themeMode: _themeMode, onThemeModeChanged: _changeThemeMode),
    },
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case Routes.detail:
          final args = settings.arguments as SessionDetailArgs;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => SessionDetailScreen(args: args),
          );
        case Routes.form:
          final args = settings.arguments as SessionFormArgs;
          return MaterialPageRoute<Session>(
            settings: settings,
            builder: (_) => SessionFormScreen(args: args),
          );
      }
      return null;
    },
    onUnknownRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text("This screen doesn't exist.")),
      ),
    ),
  );
}
