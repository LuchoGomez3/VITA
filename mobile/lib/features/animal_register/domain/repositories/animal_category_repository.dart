import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';

/// Fuente de dominio del catalogo global de categorias animales.
abstract class AnimalCategoryRepository {
  /// Obtiene las categorias activas disponibles en la cache offline.
  Future<Result<List<AnimalCategory>>> getCategories();
}
