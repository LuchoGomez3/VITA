import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_draft_repository.dart';

/// Guarda el progreso de una venta antes de su confirmación definitiva.
class SaveLivestockSaleDraftUseCase {
  /// Crea el caso de uso sobre el contrato de persistencia local.
  const SaveLivestockSaleDraftUseCase(this._repository);

  final LivestockSaleDraftRepository _repository;

  /// Persiste una instantánea cifrada del flujo.
  Future<Result<void>> call({
    required String userId,
    required LivestockSaleSavedDraft draft,
  }) => _repository.save(userId: userId, draft: draft);
}
