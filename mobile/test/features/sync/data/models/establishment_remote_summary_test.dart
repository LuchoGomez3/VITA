import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/sync/data/models/establishment_remote_summary.dart';

void main() {
  test('parses and serializes the establishment membership role', () {
    final establishment = EstablishmentRemoteSummary.fromJson({
      ..._baseJson,
      'rol': 'admin',
    });

    expect(establishment.role, UserRole.admin);
    expect(establishment.toJson()['role'], 'admin');
  });

  test('maps missing or invalid roles to unknown without throwing', () {
    expect(
      EstablishmentRemoteSummary.fromJson(_baseJson).role,
      UserRole.unknown,
    );
    expect(
      EstablishmentRemoteSummary.fromJson({
        ..._baseJson,
        'rol': 42,
      }).role,
      UserRole.unknown,
    );
  });
}

const _baseJson = <String, Object?>{
  'id': 'establishment-id',
  'owner_id': 'owner-id',
  'nombre': 'Campo Norte',
  'created_at': '2026-08-27T10:00:00.000Z',
  'updated_at': '2026-08-27T10:00:00.000Z',
};
