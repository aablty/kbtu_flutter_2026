import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';

void main() {
  test('FakeApi returns seeded students and counts calls', () async {
    final api = FakeApi();

    final students = await api.fetchStudents();

    expect(api.calls, 1);
    expect(students, hasLength(6));
  });

  test('FakeApi supports the empty response', () async {
    final api = FakeApi(empty: true);

    expect(await api.fetchStudents(), isEmpty);
  });
}
