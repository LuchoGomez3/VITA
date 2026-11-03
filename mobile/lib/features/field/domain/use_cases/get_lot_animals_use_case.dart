import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';

/// Recupera los animales asignados a un lote desde la caché local.
class GetLotAnimalsUseCase {
  /// Crea la consulta con su contrato de lectura.
  const GetLotAnimalsUseCase(this._repository);

  final LotAnimalRepository _repository;

  /// Lista animales vigentes del lote y establecimiento indicados.
  Future<Result<List<LotAnimalSummary>>> call({
    required String establishmentId,
    required String lotId,
  }) => _repository.getAnimals(
    establishmentId: establishmentId,
    lotId: lotId,
  );
}
