import 'dart:convert';

import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/senasa_report/data/dtos/senasa_report_dtos.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';

/// Lee el catálogo de establecimientos persistido durante la sincronización.
class SenasaEstablishmentLocalDataSource {
  /// Crea el data source sobre el almacenamiento seguro compartido.
  const SenasaEstablishmentLocalDataSource({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Obtiene el catálogo local como DTOs de infraestructura.
  Future<List<SenasaEstablishmentDto>> getEstablishments() async {
    // TODO(senasa-session): mover el catálogo y el establecimiento seleccionado
    // a una sesión compartida para que las features no dupliquen esta lectura.
    try {
      final encoded = await _secureStorage.read(
        SecureStorageKeys.establishmentCatalog,
      );
      if (encoded == null || encoded.isEmpty) {
        return const [];
      }
      final catalog = jsonDecode(encoded);
      if (catalog is! List<Object?>) {
        throw const FormatException('Invalid establishment catalog.');
      }
      return catalog.map(_parseEstablishment).toList(growable: false);
    } on Object {
      throw const SenasaReportException(
        message: 'No se pudieron leer los establecimientos guardados en el dispositivo.',
      );
    }
  }

  SenasaEstablishmentDto _parseEstablishment(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('Invalid local establishment.');
    }
    return SenasaEstablishmentDto.fromJson(value);
  }
}
