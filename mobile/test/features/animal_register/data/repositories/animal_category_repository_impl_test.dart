import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_category_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('AnimalCategoryRepositoryImpl', () {
    test('maps the cached Brick catalog to domain categories', () async {
      final repository = AnimalCategoryRepositoryImpl(
        store: _FakeCategoriaBrickStore(categories: [_category]),
      );

      final result = await repository.getCategories();

      expect(
        result,
        const Result<List<AnimalCategory>>.success([
          AnimalCategory(id: 'category-id', name: 'Ternera'),
        ]),
      );
    });

    test('returns a storage failure when SQLite cannot be read', () async {
      sqfliteFfiInit();
      final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(database.close);
      late DatabaseException readError;
      try {
        await database.query('missing_categories');
      } on DatabaseException catch (error) {
        readError = error;
      }
      final repository = AnimalCategoryRepositoryImpl(
        store: _FakeCategoriaBrickStore(readError: readError),
      );

      final result = await repository.getCategories();

      expect(result, isA<Failure<List<AnimalCategory>>>());
      expect((result as Failure<List<AnimalCategory>>).error.code, DomainErrorCode.unknown);
    });

    test('propagates programming errors', () async {
      final repository = AnimalCategoryRepositoryImpl(
        store: _FakeCategoriaBrickStore(readError: StateError('invalid state')),
      );

      await expectLater(repository.getCategories(), throwsStateError);
    });
  });
}

final _category = BrickCategoriaModel(
  localId: 'category-id',
  name: 'Ternera',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _FakeCategoriaBrickStore implements CategoriaBrickStore {
  const _FakeCategoriaBrickStore({
    this.categories = const [],
    this.readError,
  });

  final List<BrickCategoriaModel> categories;
  final Object? readError;

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias([
    String? establishmentId,
  ]) async {
    if (readError case final Object error) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    return categories;
  }

  @override
  Future<void> pullRemoteCategorias([String? establishmentId]) async {}

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) async => categoria;
}
