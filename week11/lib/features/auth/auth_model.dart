import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {required this._signedIn});

  final SecureStore _store;
  bool _signedIn;

  bool get signedIn => _signedIn;

  Future<void> login(String email, String password) async {
    if (password.length < 8) {
      throw const FormatException(
        'Password must contain at least 8 characters',
      );
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    await _store.saveToken('tok_${email.hashCode}');
    _signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _signedIn = false;
    notifyListeners();
  }

  Future<String?> readTokenForDebug() => _store.readToken();
}
