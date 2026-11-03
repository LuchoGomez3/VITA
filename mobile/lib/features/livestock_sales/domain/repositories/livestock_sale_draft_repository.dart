import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';

/// Persistencia local del trabajo todavía no confirmado por el productor.
abstract class LivestockSaleDraftRepository {
  /// Recupera el borrador aislado por usuario y establecimiento.
  Future<Result<LivestockSaleSavedDraft?>> load({
    required String userId,
    required String establishmentId,
  });

  /// Sobrescribe el último borrador conocido para el flujo actual.
  Future<Result<void>> save({
    required String userId,
    required LivestockSaleSavedDraft draft,
  });

  /// Elimina el borrador al descartarlo o confirmar la venta.
  Future<Result<void>> delete({
    required String userId,
    required String establishmentId,
  });
}
