import 'dart:convert';

import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';

/// Lee membresias del catalogo sincronizado para decisiones offline.
class EstablishmentCatalog {
  /// Crea el lector sobre la abstraccion de storage compartida.
  const EstablishmentCatalog({required SecureStorageService secureStorage}) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Devuelve las membresias validas conservadas por la ultima sincronizacion.
  Future<List<EstablishmentMembership>> getMemberships() async {
    final encoded = await _secureStorage.read(
      SecureStorageKeys.establishmentCatalog,
    );
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Invalid establishment catalog.');
    }

    return decoded.whereType<Map<String, dynamic>>().map(_fromJson).whereType<EstablishmentMembership>().toList();
  }

  /// Busca la membresia correspondiente al establecimiento solicitado.
  Future<EstablishmentMembership?> getById(String establishmentId) async {
    final memberships = await getMemberships();
    for (final membership in memberships) {
      if (membership.id == establishmentId) {
        return membership;
      }
    }
    return null;
  }

  /// Agrega o reemplaza una membresia sin descartar el resto del catalogo.
  Future<void> upsert(
    EstablishmentMembership membership, {
    Map<String, Object?> metadata = const {},
  }) async {
    final encoded = await _secureStorage.read(
      SecureStorageKeys.establishmentCatalog,
    );
    final entries = <Map<String, dynamic>>[];
    if (encoded != null && encoded.isNotEmpty) {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Invalid establishment catalog.');
      }
      entries.addAll(decoded.whereType<Map<String, dynamic>>());
    }

    entries
      ..removeWhere((entry) => entry['id'] == membership.id)
      ..add({
        ...metadata,
        'id': membership.id,
        'name': membership.name,
        'role': membership.role.backendValue,
      });
    await _secureStorage.write(
      key: SecureStorageKeys.establishmentCatalog,
      value: jsonEncode(entries),
    );
  }

  EstablishmentMembership? _fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) {
      return null;
    }
    return EstablishmentMembership(
      id: id,
      name: name,
      role: UserRolePermissions.fromBackend(
        json['role'] is String ? json['role'] as String : null,
      ),
    );
  }
}
