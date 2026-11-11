import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/new_user_screen.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');

  final users = UsersModel(UserRepository(ApiClient(http.Client())));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider.value(value: users),
      ],
      child: const App(),
    ),
  );
  unawaited(users.load());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: 'Users API',
      theme: ThemeData(colorScheme: scheme),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: settings.dark ? ThemeMode.dark : ThemeMode.light,
      home: const UsersScreen(),
      routes: {
        '/create': (_) => const NewUserScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
