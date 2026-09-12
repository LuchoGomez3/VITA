import 'package:frontend_mayoral/core/result/result.dart';

/// Lee los establecimientos disponibles para contextualizar los lotes.
abstract class FieldEstablishmentRepository {
  /// Devuelve UUID y nombre desde el catálogo offline de la sesión.
  Future<Result<Map<String, String>>> getEstablishments();
}
