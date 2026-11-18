import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';

/// Contrato offline del historial de recursos forrajeros de un lote.
abstract class LotForagePeriodRepository {
  /// Cambios locales del historial (por ejemplo, la confirmación del servidor).
  Stream<void> get changes;

  /// Períodos vigentes (no borrados) de [lotId], ordenados por inicio.
  Future<Result<List<LotForagePeriod>>> getPeriods({
    required String establishmentId,
    required String lotId,
  });

  /// Guarda el período en el celular y lo encola para sincronizar. También
  /// refleja en el lote el recurso vigente resultante.
  Future<Result<LotForagePeriod>> savePeriod(LotForagePeriod period);
}
