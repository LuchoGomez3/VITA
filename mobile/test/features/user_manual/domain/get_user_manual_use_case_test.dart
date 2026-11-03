import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/use_cases/get_user_manual_use_case.dart';

import '../user_manual_fakes.dart';

EstablishmentMembership _membership(String id, UserRole role) =>
    EstablishmentMembership(id: id, name: 'Campo $id', role: role);

Future<UserManual> _manualFor(List<EstablishmentMembership> memberships) async {
  final useCase = GetUserManualUseCase(
    repository: FakeUserManualRepository(),
    readMemberships: () async => memberships,
  );
  return ((await useCase()) as Success<UserManual>).data;
}

List<String> _titles(UserManual manual) => [for (final section in manual.sections) section.title];

void main() {
  group('GetUserManualUseCase', () {
    test('un dueño ve "Invitar a tu equipo" y "Crear un establecimiento"', () async {
      final manual = await _manualFor([_membership('1', UserRole.owner)]);

      expect(_titles(manual), [
        'Primeros pasos',
        'Registrar pesajes',
        'Invitar a tu equipo',
        'Crear un establecimiento',
      ]);
      expect(manual.userRoles, {UserRole.owner});
    });

    test('un empleado no ve las secciones de gestión', () async {
      final manual = await _manualFor([_membership('1', UserRole.employee)]);

      expect(_titles(manual), ['Primeros pasos', 'Registrar pesajes']);
    });

    test('un administrador ve invitar pero no crear establecimientos', () async {
      final manual = await _manualFor([_membership('1', UserRole.admin)]);

      expect(_titles(manual), contains('Invitar a tu equipo'));
      expect(_titles(manual), isNot(contains('Crear un establecimiento')));
    });

    test('con varios campos muestra la unión de sus roles, sin repetir', () async {
      final manual = await _manualFor([
        _membership('1', UserRole.employee),
        _membership('2', UserRole.admin),
      ]);

      expect(_titles(manual), ['Primeros pasos', 'Registrar pesajes', 'Invitar a tu equipo']);
      expect(manual.userRoles, {UserRole.employee, UserRole.admin});
    });

    test('el veterinario ve lo mismo que un empleado', () async {
      final manual = await _manualFor([_membership('1', UserRole.veterinarian)]);

      expect(_titles(manual), ['Primeros pasos', 'Registrar pesajes']);
      expect(manual.userRoles, {UserRole.employee});
    });

    test('sin establecimientos o con un rol desconocido quedan las generales', () async {
      for (final memberships in [
        <EstablishmentMembership>[],
        [_membership('1', UserRole.unknown)],
      ]) {
        final manual = await _manualFor(memberships);

        expect(_titles(manual), ['Primeros pasos', 'Registrar pesajes']);
        expect(manual.userRoles, isEmpty);
      }
    });

    test('si no se puede leer el catálogo muestra las generales', () async {
      final useCase = GetUserManualUseCase(
        repository: FakeUserManualRepository(),
        readMemberships: () async => throw const FormatException('catálogo corrupto'),
      );

      final manual = ((await useCase()) as Success<UserManual>).data;

      expect(_titles(manual), ['Primeros pasos', 'Registrar pesajes']);
    });

    test('propaga el error del repositorio', () async {
      const error = DomainException(message: 'sin manual');
      final useCase = GetUserManualUseCase(
        repository: FakeUserManualRepository(const Result.failure(error)),
        readMemberships: () async => [_membership('1', UserRole.owner)],
      );

      expect(await useCase(), const Result<UserManual>.failure(error));
    });
  });
}
