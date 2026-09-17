import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';

/// Contrato usado por features para acceder al catalogo de categorias con Brick.
///
/// Las features dependen de este contrato para no conocer los detalles internos
/// de [AppBrickRepository], SQLite, REST provider ni cola offline.
abstract class CategoriaBrickStore {
  /// Descarga el catalogo global y lo cachea para usarlo offline.
  Future<void> pullRemoteCategorias();

  /// Lee desde SQLite las categorias globales activas.
  ///
  /// Excluye bajas logicas. Es la fuente
  /// disponible sin conexion para todos los consumidores mobile.
  Future<List<BrickCategoriaModel>> getLocalCategorias();
}

/// Store Brick especifico para operaciones de categorias.
///
/// Solo realiza pull remoto y lecturas locales. Las modificaciones del catalogo
/// pertenecen al equipo de backend y nunca se encolan desde la app productiva.
class BrickCategoriaStore implements CategoriaBrickStore {
  BrickCategoriaStore._(this._repository);

  static BrickCategoriaStore? _instance;

  final AppBrickRepository _repository;

  /// Instancia compartida configurada durante el bootstrap de Brick.
  static BrickCategoriaStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickCategoriaStore has not been initialized yet.');
    }
    return store;
  }

  /// Configura el store de categorias una sola vez.
  static void configure(AppBrickRepository repository) {
    if (_instance != null) {
      return;
    }

    _instance = BrickCategoriaStore._(repository);
  }

  @override
  Future<void> pullRemoteCategorias() async {
    final remoteCategorias = await _repository.remoteProvider.get<BrickCategoriaModel>(
      repository: _repository,
      query: const Query(
        forProviders: [
          RestProviderQuery(
            request: BrickCategoriaRequestTransformer.listRequest,
          ),
        ],
      ),
    );

    final localCategorias = await _repository.getLocal<BrickCategoriaModel>();
    final localCategoriasById = {
      for (final categoria in localCategorias) categoria.localId: categoria,
    };

    for (final categoria in remoteCategorias) {
      categoria.primaryKey = localCategoriasById[categoria.localId]?.primaryKey;
      await _repository.upsertLocal<BrickCategoriaModel>(
        categoria,
      );
    }
  }

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async {
    final categorias = await _repository.getLocal<BrickCategoriaModel>();
    return categorias
        .where(
          (categoria) => categoria.deletedAt == null,
        )
        .toList()
      ..sort((first, second) => first.name.compareTo(second.name));
  }
}
