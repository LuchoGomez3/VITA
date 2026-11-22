import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';

/// Disponibilidad de un animal que otra operación necesita en el servidor.
enum AnimalRegistrationAvailability {
  /// El servidor ya conoce al animal.
  confirmed,

  /// El alta todavía puede llegar al servidor.
  waiting,

  /// El alta requiere que el usuario la revise.
  rejected,
}

/// Comprueba un alta y recupera el respaldo local si falta en el servidor.
class AnimalRegistrationRecovery {
  /// Usa el contrato y el almacenamiento del flujo de alta animal.
  const AnimalRegistrationRecovery(this._animals, this._backend);

  final BrickAnimalStore _animals;
  final GuardedBackendRequest _backend;
  static const String _path = BrickAnimalRequestTransformer.animalsPath;

  /// Resuelve la dependencia respetando la sesión que inició la operación.
  Future<AnimalRegistrationAvailability> call({
    required String id,
    required String establishmentId,
    required String authorId,
    required Future<void> Function() guard,
    required void Function() requireSession,
  }) async {
    final animal = await _animals.getAnimalById(id);
    if (animal != null && animal.establishmentId != establishmentId) return AnimalRegistrationAvailability.rejected;
    if (animal?.syncStatus == BrickAnimalSyncStatus.synchronized) return AnimalRegistrationAvailability.confirmed;
    if (await _exists(id, establishmentId, guard)) return AnimalRegistrationAvailability.confirmed;
    if (animal == null || animal.syncStatus == BrickAnimalSyncStatus.rejected) {
      return AnimalRegistrationAvailability.rejected;
    }
    final body = await _animals.recoverableRegistrationBody(animal, authorId);
    if (body == null) return AnimalRegistrationAvailability.waiting;
    String? errorCode;
    try {
      final data = (await _backend('POST', _path, guard, body: body))['data'] as Map<String, dynamic>;
      if (data['id'] != id || data['establecimiento_id'] != establishmentId) {
        throw const FormatException('Animal registration response did not match the request');
      }
    } on BackendRequestFailure catch (error) {
      if (!error.definitive) rethrow;
      if (!await _exists(id, establishmentId, guard)) errorCode = error.code ?? 'respuesta_animal_invalida';
    }
    await guard();
    await _animals.reconcileRecoveredRegistration(animal, errorCode: errorCode, requireSession: requireSession);
    return errorCode == null ? AnimalRegistrationAvailability.confirmed : AnimalRegistrationAvailability.rejected;
  }

  Future<bool> _exists(String id, String establishmentId, Future<void> Function() guard) async {
    try {
      final data = (await _backend('GET', '$_path/$id', guard))['data'] as Map<String, dynamic>;
      return data['id'] == id && data['establecimiento_id'] == establishmentId && data['deleted_at'] == null;
    } on BackendRequestFailure catch (error) {
      if (error.status == 404) return false;
      rethrow;
    }
  }
}
