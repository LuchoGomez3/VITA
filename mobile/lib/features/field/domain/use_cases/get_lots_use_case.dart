import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';

/// Recupera la colección local aislada por establecimiento.
class GetLotsUseCase {
  /// Crea el caso de uso.
  const GetLotsUseCase(this._repository);

  final LotRepository _repository;

  /// Lista lotes activos sin efectuar requests.
  Future<Result<List<Lot>>> call(String establishmentId) => _repository.getLots(establishmentId);
}
