import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:students_api/features/users/user.dart';

const _validUser = '''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net"
  }
}
''';

void main() {
  test('fromJson parses a real user response', () {
    final user = User.fromJson(jsonDecode(_validUser) as Map<String, dynamic>);

    expect(user.name, 'Leanne Graham');
    expect(user.address.city, 'Gwenborough');
    expect(user.address.geo.lat, -37.3159);
  });

  test('fromJson rejects an id with the wrong wire type', () {
    final json = jsonDecode(_validUser) as Map<String, dynamic>;
    json['id'] = '1';

    expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
  });
}
