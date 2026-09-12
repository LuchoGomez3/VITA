import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/auth/data/models/stored_auth_session.dart';

void main() {
  test('does not persist a global user role', () {
    final session = StoredAuthSession.fromJson({
      'access_token': 'access-token',
      'refresh_token': 'refresh-token',
      'access_token_expires_at': '2026-08-27T10:00:00.000Z',
      'user_id': 'user-id',
      'email': 'user@example.com',
      'first_name': 'Ana',
      'last_name': 'Perez',
      'role': 'admin',
    });

    expect(session.toJson(), isNot(contains('role')));
  });
}
