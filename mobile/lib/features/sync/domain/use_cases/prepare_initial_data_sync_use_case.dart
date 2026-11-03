import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';

/// Caso de uso que prepara datos offline despues de autenticar una sesion.
///
/// Es el punto de entrada de presentation hacia la sync inicial. Mantenerlo como
/// caso de uso evita que `LoginBloc` conozca stores Brick, data sources remotos
/// o marcadores de secure storage.
class PrepareInitialDataSyncUseCase {
  /// Crea el caso de uso con el repositorio de sync inicial.
  const PrepareInitialDataSyncUseCase(this._repository);

  final InitialDataSyncRepository _repository;

  /// Ejecuta la actualizacion de los datos disponibles sin parametros de usuario.
  ///
  /// La sesion y el token autenticado determinan el alcance en el backend. Un
  /// resultado exitoso informa los establecimientos disponibles para que el
  /// flujo llamador decida su proximo destino. Una falla no invalida la sesion.
  Future<Result<PostAuthenticationSummary>> call() {
    return _repository.sync();
  }
}
