import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';

void main() {
  test('does not expose tokens in its string representation', () {
    final session = AuthSession(
      user: const AppUser(
        id: 'user-id',
        email: 'user@example.com',
        firstName: 'Juan',
        lastName: 'Perez',
      ),
      accessToken: 'sensitive-access-token',
      refreshToken: 'sensitive-refresh-token',
      accessTokenExpiresAt: DateTime.utc(2026),
    );

    expect(session.toString(), isNot(contains('sensitive-access-token')));
    expect(session.toString(), isNot(contains('sensitive-refresh-token')));
    expect(session.toString(), contains('tokens: ***'));
  });
}
