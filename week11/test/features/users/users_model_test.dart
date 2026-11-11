import 'package:flutter_test/flutter_test.dart';
import 'package:students_api/core/api/api_exception.dart';
import 'package:students_api/features/users/fake_user_repository.dart';
import 'package:students_api/features/users/users_model.dart';

void main() {
  test('load puts repository items into the model', () async {
    final model = UsersModel(FakeUserRepository());

    await model.load();

    expect(model.items, hasLength(2));
    expect(model.loading, isFalse);
    expect(model.error, isNull);
  });

  test('load stores NoConnectionException as the error', () async {
    final model = UsersModel(FakeUserRepository(fail: true));

    await model.load();

    expect(model.error, isA<NoConnectionException>());
    expect(model.loading, isFalse);
  });
}
