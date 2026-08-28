import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Recupera el detalle local de un lote.
class GetLotUseCase {
  /// Crea el caso de uso.
  const GetLotUseCase(this._repository);

  final LotRepository _repository;

  /// Busca por UUID sin red.
  Future<Result<Lot>> call(String lotId) => _repository.getLot(lotId);
}
