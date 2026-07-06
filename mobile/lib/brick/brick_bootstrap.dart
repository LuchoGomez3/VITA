import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Inicializa Brick antes de que arranque la app.
///
/// Este bootstrap prepara la infraestructura offline-first compartida:
/// - Define donde viven las bases SQLite locales.
/// - Configura [AppBrickRepository], que maneja providers, migraciones y cola.
/// - Configura los stores por entidad que consumen esa infraestructura.
///
/// No es un bootstrap del backend. Todo esto corre en el dispositivo mobile.
class BrickBootstrap {
  const BrickBootstrap._();

  /// Configura el repositorio Brick compartido y sus bases locales.
  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();

    // Base principal de datos offline-first: tablas de modelos Brick.
    final sqlitePath = path.join(directory.path, 'vita_brick.sqlite');

    // Base separada que Brick usa para requests REST pendientes/reintentables.
    final offlineQueuePath = path.join(directory.path, 'vita_brick_offline_queue.sqlite');

    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: offlineQueuePath,
    );

    // Stores por entidad. A medida que sumemos modelos Brick, aca se registran
    // stores como BrickPesajeStore, BrickMovimientoStore, etc.
    BrickAnimalStore.configure(AppBrickRepository.instance);
  }
}
