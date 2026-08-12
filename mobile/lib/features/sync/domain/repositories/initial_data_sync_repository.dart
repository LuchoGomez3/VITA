import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';

/// Contrato para preparar datos locales despues del primer login de un usuario.
///
/// Vive en `features/sync` porque la descarga de tablas offline no pertenece al
/// dominio de autenticacion. Auth solo dispara esta preparacion una vez que hay
/// una sesion valida y un token disponible para Brick/backend.
abstract class InitialDataSyncRepository {
  /// Sincroniza los datos necesarios para operar offline con [userId].
  ///
  /// Debe ser idempotente: si el bootstrap ya se completo para ese usuario,
  /// puede terminar sin volver a descargar las entidades.
  Future<Result<PostAuthenticationSummary>> syncForUser(String userId);
}
