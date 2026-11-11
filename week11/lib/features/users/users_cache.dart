import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}users.json');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode([for (final user in users) user.toJson()]),
    );
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
    return [
      for (final item in decoded) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
