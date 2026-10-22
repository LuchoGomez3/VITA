import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/features/sync/sync_composition.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';
import 'package:frontend_mayoral/features/team/team_composition.dart';

/// Comparte el repositorio entre rutas y lo reemplaza al cambiar de identidad.
/// La aplicación conecta Team con Sync; el router solo solicita dependencias.
TeamRepository Function() createSessionTeamRepositoryFactory() {
  TeamRepository? repository;
  int? session;
  return () {
    final generation = SessionBackendAccessTokenProvider.instance.sessionGeneration;
    if (repository == null || session != generation) {
      session = generation;
      repository = createTeamRepository(updateCatalog: createOfflineSyncCoordinator().updateCatalog);
    }
    return repository!;
  };
}
