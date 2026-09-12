import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/auth/data/mappers/app_user_mapper.dart';

void main() {
  test('maps auth me without reading a global role', () {
    final user = AppUserMapper.fromJson({
      'id': 'user-id',
      'email': 'user@example.com',
      'nombre': 'Ana',
      'apellido': 'Perez',
      'rol': 'admin',
      'role': 'owner',
    });

    expect(user.id, 'user-id');
    expect(user.firstName, 'Ana');
  });
}
