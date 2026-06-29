/// Resultado generico de una request de sincronizacion contra el backend.
///
/// El cliente HTTP compartido no deberia conocer entidades concretas como
/// animales, lotes o pesajes. Solo publica que una request sync-able termino
/// para cierto recurso, y cada store decide si ese evento le corresponde.
class BackendSyncResult {
  /// Crea el resultado observado desde una response del backend.
  const BackendSyncResult({
    required this.resourcePath,
    required this.localId,
    required this.synchronized,
    this.errorCode,
  });

  /// Path del recurso sincronizado, por ejemplo `/api/v1/animales`.
  final String resourcePath;

  /// UUID generado por el cliente y enviado como `id` al backend.
  final String localId;

  /// Indica si el backend acepto el registro.
  final bool synchronized;

  /// Codigo funcional del backend cuando el sync fue rechazado.
  final String? errorCode;
}

/// Callback invocado despues de que el backend responde una request sync-able.
typedef BackendSyncResultHandler =
    Future<void> Function(
      BackendSyncResult result,
    );
