import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';

/// Contrato que entrega los datos complementarios mostrados en Perfil.
abstract class ProfileRepository {
  /// Lee todos los establecimientos guardados para la sesión actual.
  Future<Result<List<EstablishmentDetails>>> getEstablishments();
}
