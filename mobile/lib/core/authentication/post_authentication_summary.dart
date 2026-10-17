import 'package:frontend_mayoral/core/result/result.dart';

/// Resultado compartido del procesamiento posterior a una autenticacion.
class PostAuthenticationSummary {
  /// Crea el resumen con los establecimientos visibles para el usuario.
  PostAuthenticationSummary({required List<String> establishmentIds})
    : establishmentIds = List.unmodifiable(establishmentIds);

  /// IDs informados por el backend durante la preparacion local.
  final List<String> establishmentIds;

  /// Indica si el usuario ya tiene al menos un establecimiento configurado.
  bool get hasEstablishments => establishmentIds.isNotEmpty;
}

/// Operacion reutilizable posterior a cualquier autenticacion exitosa.
typedef PreparePostAuthentication = Future<Result<PostAuthenticationSummary>> Function();
