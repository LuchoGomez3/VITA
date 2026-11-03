import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Obtiene los lotes activos que pueden recibir animales desde otro lote.
class GetAvailableDestinationLotsUseCase {
  /// Crea la consulta sobre el repositorio de lotes.
  const GetAvailableDestinationLotsUseCase(this._repository);

  final LotRepository _repository;

  /// Excluye el lote de origen y cualquier lote que no este activo.
  Future<Result<List<Lot>>> call({
    required String establishmentId,
    required String sourceLotId,
  }) async {
    final result = await _repository.getLots(establishmentId);
    if (result case Success<List<Lot>>(:final data)) {
      return Success(
        data
            .where(
              (lot) => lot.id != sourceLotId && lot.status == LotStatus.active,
            )
            .toList(growable: false),
      );
    }
    return result;
  }
}
