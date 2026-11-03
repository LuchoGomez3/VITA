import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_category_repository.dart';

/// Obtiene el catalogo global de categorias animales disponible offline.
class GetAnimalCategoriesUseCase {
  /// Crea el caso de uso con su repositorio de dominio.
  const GetAnimalCategoriesUseCase(this._repository);

  final AnimalCategoryRepository _repository;

  /// Lee las categorias activas desde la fuente local de la aplicacion.
  Future<Result<List<AnimalCategory>>> call() => _repository.getCategories();
}
