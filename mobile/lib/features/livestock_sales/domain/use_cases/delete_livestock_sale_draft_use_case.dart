import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_draft_repository.dart';

/// Descarta el progreso local de una venta que ya no debe recuperarse.
class DeleteLivestockSaleDraftUseCase {
  /// Crea el caso de uso sobre el contrato de persistencia local.
  const DeleteLivestockSaleDraftUseCase(this._repository);

  final LivestockSaleDraftRepository _repository;

  /// Elimina el borrador del usuario y establecimiento indicados.
  Future<Result<void>> call({
    required String userId,
    required String establishmentId,
  }) => _repository.delete(
    userId: userId,
    establishmentId: establishmentId,
  );
}
