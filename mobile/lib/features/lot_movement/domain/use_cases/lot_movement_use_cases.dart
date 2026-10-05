import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/repositories/lot_movement_repository.dart';

/// Obtiene el contexto sin exponer repositorios a presentación.
class LoadMovementContextUseCase {
  /// Recibe el contrato de dominio.
  const LoadMovementContextUseCase(this._repository);
  final LotMovementRepository _repository;

  /// La lectura local permite pintar la pantalla antes de intentar red.
  Future<Result<MovementContext>> call(String establishmentId, {bool refreshRemote = false}) =>
      _repository.getContext(establishmentId, refreshRemote: refreshRemote);

  /// Observa los resultados que ya fueron guardados localmente.
  Stream<void> get changes => _repository.changes;
}

/// Valida selección, UUID, origen compartido y destino antes de crear un comando.
class SaveLotMovementUseCase {
  /// Inyecta el generador de UUID y el reloj para probar reintentos y fechas.
  const SaveLotMovementUseCase(this._repository, {required String Function() createId, DateTime Function()? now})
    : _createId = createId,
      _now = now;
  final LotMovementRepository _repository;
  final String Function() _createId;
  final DateTime Function()? _now;
  static final _uuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  /// No deduplica silenciosamente ni mezcla orígenes: rechaza la selección inválida.
  Future<Result<AnimalLotMovement>> call({
    required String establishmentId,
    required String? sourceLotId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
  }) async {
    if (animalIds.isEmpty ||
        animalIds.toSet().length != animalIds.length ||
        reason.trim().isEmpty ||
        !_uuid.hasMatch(establishmentId) ||
        !_uuid.hasMatch(destinationLotId) ||
        (sourceLotId != null && !_uuid.hasMatch(sourceLotId)) ||
        animalIds.any((id) => !_uuid.hasMatch(id))) {
      return const Result.failure(
        DomainException(
          message: 'Seleccioná animales válidos sin repetir, un destino y un motivo.',
          code: DomainErrorCode.validation,
        ),
      );
    }
    final context = await _repository.getContext(establishmentId);
    if (context case Failure<MovementContext>(:final error)) return Result.failure(error);
    final data = (context as Success<MovementContext>).data;
    final selected = data.animals.where((a) => animalIds.contains(a.id)).toList();
    if (selected.length != animalIds.length || selected.any((a) => a.lotId != sourceLotId || !a.canMove)) {
      return const Result.failure(
        DomainException(
          message: 'Seleccioná animales del mismo origen sin otro traslado pendiente o rechazado.',
          code: DomainErrorCode.conflict,
        ),
      );
    }
    if (sourceLotId == destinationLotId || !data.destinations.any((lot) => lot.id == destinationLotId)) {
      return const Result.failure(
        DomainException(message: 'Elegí otro lote activo del establecimiento.', code: DomainErrorCode.validation),
      );
    }
    final now = (_now?.call() ?? DateTime.now()).toUtc();
    return _repository.save(
      AnimalLotMovement(
        id: _createId(),
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIds: animalIds,
        occurredAt: occurredAt.toUtc(),
        reason: reason.trim(),
        createdAt: now,
      ),
    );
  }
}

/// Reintenta el movimiento existente: no repite selección ni cambia el payload.
class RetryLotMovementUseCase {
  /// Recibe el contrato de persistencia.
  const RetryLotMovementUseCase(this._repository);
  final LotMovementRepository _repository;

  /// El mismo ID evita duplicar el hecho histórico si el servidor ya lo recibió.
  Future<Result<void>> call(String movementId) => _repository.retry(movementId);
}
