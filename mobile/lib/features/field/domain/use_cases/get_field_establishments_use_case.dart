import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/field_establishment_repository.dart';

/// Obtiene el contexto multi-tenant disponible sin conectividad.
class GetFieldEstablishmentsUseCase {
  /// Crea el caso de uso.
  const GetFieldEstablishmentsUseCase(this._repository);

  final FieldEstablishmentRepository _repository;

  /// Devuelve el catálogo local.
  Future<Result<Map<String, String>>> call() => _repository.getEstablishments();
}
