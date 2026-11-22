import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/repositories/health_repository.dart';

/// Error que la presentación puede traducir a un mensaje de Sanidad.
enum HealthProblem {
  /// El establecimiento no está disponible para esta cuenta.
  unauthorized,

  /// El catálogo del establecimiento aún no está disponible.
  catalogUnavailable,

  /// La práctica o el producto ya no están habilitados.
  unavailablePractice,

  /// Faltan datos específicos de la práctica.
  invalidDetails,

  /// La lista está vacía o contiene duplicados.
  invalidSelection,

  /// Un animal de la selección dejó de estar disponible.
  unavailableAnimal,

  /// El RFID todavía no contiene quince dígitos.
  invalidTag,

  /// Hay más de un animal con la misma identificación.
  ambiguousTag,

  /// El estudio no acepta el resultado solicitado.
  invalidResult,
}

/// Error de dominio de Sanidad.
class HealthFailure implements Exception {
  /// Crea un error traducible por su [problem].
  const HealthFailure(this.problem);

  /// Motivo de la operación rechazada.
  final HealthProblem problem;
}

/// Valida una carga usando el catálogo vigente y guarda el grupo.
class RegisterHealthEventsUseCase {
  /// Crea el caso de uso.
  const RegisterHealthEventsUseCase(this._repository);

  final HealthRepository _repository;

  /// Ejecuta la validación sin consultar la red.
  Future<void> call(HealthRegistration registration, {String? replacingOperationId}) async {
    final catalog = await _repository.getCatalog(registration.establishmentId);
    if (catalog == null) throw const HealthFailure(HealthProblem.catalogUnavailable);
    validate(registration, catalog);
    await _repository.register(registration, replacingOperationId: replacingOperationId);
  }

  /// Verifica el catálogo, los datos de la práctica y la selección revisada.
  static void validate(HealthRegistration registration, HealthCatalog catalog) {
    final practice = catalog.practices.where((value) => value.id == registration.practice.id).firstOrNull;
    if (catalog.establishmentId != registration.establishmentId || practice?.kind != registration.practice.kind) {
      throw const HealthFailure(HealthProblem.unavailablePractice);
    }
    final ids = registration.recipients.map((item) => item.animalId).toSet();
    if (ids.isEmpty || ids.contains('') || ids.length != registration.recipients.length) {
      throw const HealthFailure(HealthProblem.invalidSelection);
    }
    if (registration.responsible.trim().isEmpty) throw const HealthFailure(HealthProblem.invalidDetails);

    switch ((registration.practice.kind, registration.details)) {
      case (HealthPracticeKind.application, final HealthApplication details):
        final dose = double.tryParse(details.dose.replaceAll(',', '.'));
        if (!practice!.productIds.contains(details.productId) ||
            !catalog.products.any((product) => product.id == details.productId)) {
          throw const HealthFailure(HealthProblem.unavailablePractice);
        }
        if (dose == null ||
            !dose.isFinite ||
            dose <= 0 ||
            details.unit.trim().isEmpty ||
            details.route.trim().isEmpty) {
          throw const HealthFailure(HealthProblem.invalidDetails);
        }
      case (HealthPracticeKind.sampling, final HealthObservation details):
        if (details.description.trim().isEmpty || (details.sampleType?.trim().isEmpty ?? true)) {
          throw const HealthFailure(HealthProblem.invalidDetails);
        }
      case (HealthPracticeKind.lesion, final HealthObservation details):
        if (details.description.trim().isEmpty || details.sampleType != null) {
          throw const HealthFailure(HealthProblem.invalidDetails);
        }
      default:
        throw const HealthFailure(HealthProblem.invalidDetails);
    }

    if (registration.practice.kind != HealthPracticeKind.sampling &&
        registration.recipients.any((item) => item.sampleReference != null)) {
      throw const HealthFailure(HealthProblem.invalidDetails);
    }
  }
}

/// Consulta local y resolución de la selección sanitaria.
class ReadHealthUseCase {
  /// Crea el caso de uso.
  const ReadHealthUseCase(this._repository);

  final HealthRepository _repository;

  /// Lee el catálogo del establecimiento.
  Future<HealthCatalog?> catalog(String establishmentId) => _repository.getCatalog(establishmentId);

  /// Lee el conjunto precargado.
  Future<List<HealthRecipient>> recipients(String establishmentId, List<String> ids) =>
      _repository.getRecipients(establishmentId, ids);

  /// Resuelve una lectura individual.
  Future<HealthRecipient?> find(String establishmentId, String tag, {required bool electronic}) =>
      _repository.findRecipient(establishmentId, tag, electronic: electronic);

  /// Observa el historial local del animal.
  Stream<List<HealthEvent>> history(String establishmentId, String animalId) =>
      _repository.watchHistory(establishmentId, animalId);

  /// Recupera una carga rechazada para corregirla.
  Future<HealthCorrection?> rejectedRegistration(HealthEvent event) => _repository.getRejectedRegistration(event);
}

/// Guarda el primer resultado o corrige su envío rechazado.
class RecordHealthResultUseCase {
  /// Crea el caso de uso.
  const RecordHealthResultUseCase(this._repository);

  final HealthRepository _repository;

  /// Actualiza el estudio existente.
  Future<void> call(HealthEvent event, String result, DateTime reportedAt) {
    final cleaned = result.trim();
    if (event.practice.kind != HealthPracticeKind.sampling ||
        cleaned.isEmpty ||
        (event.result != null && event.resultSyncStatus != HealthSyncStatus.rejected)) {
      throw const HealthFailure(HealthProblem.invalidResult);
    }
    return _repository.recordResult(event, cleaned, reportedAt);
  }
}
