import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_draft_repository.dart';

/// Recupera una venta incompleta del usuario y establecimiento actuales.
class LoadLivestockSaleDraftUseCase {
  /// Crea el caso de uso sobre el contrato de persistencia local.
  const LoadLivestockSaleDraftUseCase(this._repository);

  final LivestockSaleDraftRepository _repository;

  /// Busca el borrador sin requerir conectividad.
  Future<Result<LivestockSaleSavedDraft?>> call({
    required String userId,
    required String establishmentId,
  }) => _repository.load(
    userId: userId,
    establishmentId: establishmentId,
  );
}
