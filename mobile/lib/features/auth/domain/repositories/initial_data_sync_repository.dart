import 'package:frontend_mayoral/core/result/result.dart';

/// Contrato para preparar datos locales despues del primer login de un usuario.
abstract class InitialDataSyncRepository {
  /// Sincroniza los datos necesarios para operar offline con [userId].
  Future<Result<void>> syncForUser(String userId);
}
