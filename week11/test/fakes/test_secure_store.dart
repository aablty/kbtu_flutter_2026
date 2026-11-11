import 'package:students_api/core/storage/secure_store.dart';

class TestSecureStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;
}
