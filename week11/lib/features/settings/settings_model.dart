import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this.dark,
    this.city,
    required this.apiHost,
  });

  final SharedPreferencesAsync _prefs;
  bool dark;
  String? city;
  String apiHost;

  Future<void> setDark(bool value) async {
    if (dark == value) return;
    dark = value;
    notifyListeners();
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setCity(String? value) async {
    if (city == value) return;
    city = value;
    notifyListeners();
    if (value == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', value);
    }
  }

  Future<void> setApiHost(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == apiHost) return;
    apiHost = normalized;
    notifyListeners();
    await _prefs.setString('apiHost', normalized);
  }
}
