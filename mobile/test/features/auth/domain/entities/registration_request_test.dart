import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';

void main() {
  test('does not expose registration data in its text representation', () {
    const request = RegistrationRequest(
      firstName: 'Ernesto',
      lastName: 'Diaz',
      email: 'ernesto@example.com',
      cuit: '20-12345678-6',
      password: 'Password1',
    );

    expect(request.toString(), 'RegistrationRequest(password: ***)');
    expect(request.toString(), isNot(contains(request.password)));
    expect(request.toString(), isNot(contains(request.email)));
    expect(request.toString(), isNot(contains(request.cuit)));
  });
}
