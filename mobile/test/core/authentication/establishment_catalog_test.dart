import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';

void main() {
  test('restores different roles for the same user by establishment', () async {
    final storage = _MemoryStorage();
    await storage.write(
      key: SecureStorageKeys.establishmentCatalog,
      value: jsonEncode([
        {'id': 'north', 'name': 'Campo Norte', 'role': 'owner'},
        {'id': 'south', 'name': 'Campo Sur', 'role': 'employee'},
      ]),
    );
    final catalog = EstablishmentCatalog(secureStorage: storage);

    expect((await catalog.getById('north'))?.role, UserRole.owner);
    expect((await catalog.getById('south'))?.role, UserRole.employee);
  });

  test('uses unknown for missing and invalid offline roles', () async {
    final storage = _MemoryStorage();
    await storage.write(
      key: SecureStorageKeys.establishmentCatalog,
      value: jsonEncode([
        {'id': 'missing-role', 'name': 'Campo Uno'},
        {'id': 'invalid-role', 'name': 'Campo Dos', 'role': 'legacy-role'},
      ]),
    );
    final useCase = GetEstablishmentRoleUseCase(
      EstablishmentCatalog(secureStorage: storage),
    );

    expect(await useCase('missing-role'), UserRole.unknown);
    expect(await useCase('invalid-role'), UserRole.unknown);
    expect(await useCase('not-stored'), UserRole.unknown);
  });
}

class _MemoryStorage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
