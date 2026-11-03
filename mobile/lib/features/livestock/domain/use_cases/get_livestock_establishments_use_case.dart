import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';

/// Obtiene establecimientos habilitados para identificar animales.
class GetLivestockEstablishmentsUseCase {
  /// Crea el caso de uso con el contrato offline de Hacienda.
  const GetLivestockEstablishmentsUseCase(this._repository);

  final LivestockEstablishmentRepository _repository;

  /// Excluye roles ausentes o desconocidos para fallar cerrado.
  Future<Result<List<LivestockEstablishment>>> call() async {
    final result = await _repository.getEstablishments();
    return result.when(
      success: (data) => Result.success(
        data.where((establishment) => establishment.canIdentifyAnimals).toList(growable: false),
      ),
      failure: Result.failure,
    );
  }
}
