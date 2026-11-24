import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_detail_animal_repository.dart';

/// Recupera desde SQLite los animales que integran una venta.
class GetLivestockSaleDetailAnimalsUseCase {
  /// Crea el caso de uso con el repositorio local del establecimiento.
  const GetLivestockSaleDetailAnimalsUseCase(this._repository);

  final LivestockSaleDetailAnimalRepository _repository;

  /// Consulta los UUID persistidos en la venta sin requerir conectividad.
  Future<Result<List<LivestockSaleAnimal>>> call(List<String> animalIds) {
    return _repository.findLocalByIds(animalIds);
  }
}
