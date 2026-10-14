import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';

/// Obtiene los establecimientos donde el usuario puede registrar ventas.
class GetLivestockSaleEstablishmentsUseCase {
  /// Crea el caso de uso sobre el catalogo offline de Hacienda.
  const GetLivestockSaleEstablishmentsUseCase(this._repository);

  final LivestockEstablishmentRepository _repository;

  /// Filtra las membresias con la misma regla comercial aplicada por backend.
  Future<Result<List<EstablishmentMembership>>> call() async {
    final result = await _repository.getEstablishments();
    return result.when(
      success: (data) => Result.success(
        data.where((membership) => membership.role.canRegisterLivestockSale).toList(growable: false),
      ),
      failure: Result.failure,
    );
  }
}
