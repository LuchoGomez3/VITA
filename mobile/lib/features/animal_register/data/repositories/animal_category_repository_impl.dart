import 'package:frontend_mayoral/brick/models/categoria.model.dart';
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

  // Categorías globales de 20261001_02. Permiten usar los registros de SQLite
  // que todavía no tienen sexo_permitido, incluso sin conexión.
  static const Map<String, AnimalCategorySex> _cachedGlobalRules = {
    'd37e62fb-96db-4ff1-a26b-0e3b2c3b36d8': AnimalCategorySex.female, // Ternera
    'b6d6440c-88c6-48cc-9003-0ad2cc05f3d5': AnimalCategorySex.female, // Vaquillona
    'ef69117b-c979-4665-b13f-2b26ff0f19b3': AnimalCategorySex.female, // Vaca
    'b9a6e57b-20ae-49b1-a7bb-17c71af546f3': AnimalCategorySex.male, // Ternero
    '41da4271-bd25-4ba0-ba34-24dc6586f0f2': AnimalCategorySex.male, // Novillo
    'b5e8ea91-9789-4f7e-9dad-10262f1920f4': AnimalCategorySex.male, // Toro
  };

  @override
  Future<Result<List<AnimalCategory>>> getCategories() async {
    try {
      final stored = await _store.getLocalCategorias();
      return Result.success(
        stored.map(_toSelectableCategory).nonNulls.toList(growable: false),
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

  /// Descarta categorías de prueba y filas que todavía no tienen una regla
  /// verificable, para evitar altas que el backend rechazaría al sincronizar.
  static AnimalCategory? _toSelectableCategory(BrickCategoriaModel category) {
    final name = category.name.trim().toLowerCase().replaceAll('á', 'a');
    if (name == 'engorde rapido' || category.localId == '550e8400-e29b-41d4-a716-446655440034') return null;

    final allowedSex = switch (category.allowedSex) {
      'hembra' => AnimalCategorySex.female,
      'macho' => AnimalCategorySex.male,
      'ambos' => AnimalCategorySex.both,
      null => _cachedGlobalRules[category.localId],
      _ => null,
    };
    if (allowedSex == null) return null;
    return AnimalCategory(id: category.localId, name: category.name, allowedSex: allowedSex);
  }
}
