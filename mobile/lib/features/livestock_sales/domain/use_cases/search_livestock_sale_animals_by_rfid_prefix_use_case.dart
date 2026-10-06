import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';

/// Busca coincidencias RFID en el inventario local mientras se escribe.
class SearchLivestockSaleAnimalsByRfidPrefixUseCase {
  /// Crea la búsqueda sobre el repositorio offline de animales.
  const SearchLivestockSaleAnimalsByRfidPrefixUseCase({
    required LivestockSaleAnimalRepository repository,
  }) : _repository = repository;

  final LivestockSaleAnimalRepository _repository;

  /// Devuelve coincidencias por prefijo sin requerir conectividad.
  Future<Result<List<LivestockSaleAnimal>>> call(String prefix) {
    final normalizedPrefix = prefix.trim();
    if (normalizedPrefix.isEmpty) return Future.value(const Result.success([]));
    return _repository.findLocalByRfidPrefix(normalizedPrefix);
  }
}
