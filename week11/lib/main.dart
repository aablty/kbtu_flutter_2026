import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/env.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/users/user_repository.dart';
import 'features/users/fake_user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/new_user_screen.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/settings/settings_screen.dart';
import 'features/about/about_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final apiHost = await prefs.getString('apiHost') ?? Env.host;
  const store = SecureStore();
  final token = await store.readToken();

  final UserRepository repo = Env.useFakes
      ? FakeUserRepository()
      : HttpUserRepository(
          ApiClient.production(store, host: apiHost),
          UsersCache(),
        );
  final users = UsersModel(repo);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, apiHost: apiHost),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(store, signedIn: token != null),
        ),
        ChangeNotifierProvider.value(value: users),
      ],
      child: App(prefs: prefs),
    ),
  );
  unawaited(users.load());
}

class App extends StatelessWidget {
  const App({required this.prefs, super.key});

  final SharedPreferencesAsync prefs;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final auth = context.watch<AuthModel>();
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
      home: auth.signedIn ? const UsersScreen() : const LoginScreen(),
      routes: {
        '/create': (_) => const NewUserScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => ProfileScreen(prefs: prefs),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}
