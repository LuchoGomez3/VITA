import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_forage_period_repository.dart';

/// Lee el historial de recursos de un lote desde el celular.
class GetLotForagePeriodsUseCase {
  /// Crea el caso de uso.
  const GetLotForagePeriodsUseCase(this._repository);

  final LotForagePeriodRepository _repository;

  /// Cambios locales que requieren releer el historial.
  Stream<void> get changes => _repository.changes;

  /// Períodos vigentes de [lotId], del más antiguo al más reciente.
  Future<Result<List<LotForagePeriod>>> call({
    required String establishmentId,
    required String lotId,
  }) => _repository.getPeriods(establishmentId: establishmentId, lotId: lotId);
}
