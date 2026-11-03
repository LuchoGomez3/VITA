import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_category_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Implementacion offline-first del catalogo de categorias del registro.
class AnimalCategoryRepositoryImpl implements AnimalCategoryRepository {
  /// Crea el repositorio sobre el store Brick compartido.
  const AnimalCategoryRepositoryImpl({required CategoriaBrickStore store}) : _store = store;

  final CategoriaBrickStore _store;
  static final Logger _logger = Logger('AnimalCategoryRepository');

  @override
  Future<Result<List<AnimalCategory>>> getCategories() async {
    try {
      final stored = await _store.getLocalCategorias();
      return Result.success(
        stored.map((category) => AnimalCategory(id: category.localId, name: category.name)).toList(growable: false),
      );
    } on DatabaseException catch (error, stackTrace) {
      _logger.severe('Failed to read local animal categories', error, stackTrace);
      return const Result.failure(
        DomainException(
          message: 'No se pudieron cargar las categorias guardadas.',
        ),
      );
    }
  }
}
