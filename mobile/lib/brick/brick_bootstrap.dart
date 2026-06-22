import 'package:frontend_mayoral/brick/repository.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Initializes Brick once before the app starts.
class BrickBootstrap {
  const BrickBootstrap._();

  /// Configures the shared Brick repository and local databases.
  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final sqlitePath = path.join(directory.path, 'vita_brick.sqlite');
    final offlineQueuePath = path.join(directory.path, 'vita_brick_offline_queue.sqlite');

    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: offlineQueuePath,
    );
  }
}
