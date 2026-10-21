import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/repositories/quick_read_repository.dart';

final _rfidPattern = RegExp(r'^\d{15}$');

/// Convierte una caravana leída (bastón o teclado) en un ítem de la sesión.
///
/// A diferencia de "Mover animales", un RFID válido que no está en el celular
/// no es un error: queda como caravana sin registrar para darla de alta.
class ResolveQuickReadTagUseCase {
  /// Crea el caso de uso.
  const ResolveQuickReadTagUseCase(this._repository);

  final QuickReadRepository _repository;

  /// Resuelve [tag] para la sesión de [establishmentId] (`null` si todavía no
  /// se fijó) sin repetir lo que ya está en [items].
  Future<Result<QuickReadItem>> call({
    required String tag,
    required String? establishmentId,
    required List<QuickReadItem> items,
  }) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(
        DomainException(message: 'Leé o escribí una caravana.', code: DomainErrorCode.validation),
      );
    }
    final found = await _repository.findByTag(trimmed);
    if (found is Failure<QuickReadAnimal?>) {
      return Result.failure(found.error);
    }
    final animal = (found as Success<QuickReadAnimal?>).data;
    if (animal != null) {
      if (establishmentId != null && animal.animal.establishmentId != establishmentId) {
        return const Result.failure(
          DomainException(
            message: 'Ese animal es de otro establecimiento. Leé solo animales de un mismo campo.',
            code: DomainErrorCode.validation,
          ),
        );
      }
      if (items.any((item) => item is RegisteredRead && item.animal.animal.id == animal.animal.id)) {
        return Result.failure(
          DomainException(
            message: 'La caravana ${animal.animal.visualTag} ya está en la lista.',
            code: DomainErrorCode.conflict,
          ),
        );
      }
      return Result.success(RegisteredRead(animal));
    }

    final digits = trimmed.replaceAll(RegExp(r'\s'), '');
    if (!_rfidPattern.hasMatch(digits)) {
      return Result.failure(
        DomainException(
          message:
              'No hay ningún animal activo con la caravana $trimmed. Para darlo de alta leé su RFID de 15 dígitos.',
          code: DomainErrorCode.notFound,
        ),
      );
    }
    if (items.any((item) => item is UnregisteredRead && item.rfidTagNumber == digits)) {
      return Result.failure(
        DomainException(message: 'La caravana $digits ya está en la lista.', code: DomainErrorCode.conflict),
      );
    }
    return Result.success(UnregisteredRead(digits));
  }
}

/// Vuelve a leer la sesión después de una acción: los potreros y los pesos
/// cambian, y una caravana dada de alta pasa a registrada.
class RefreshQuickReadUseCase {
  /// Crea el caso de uso.
  const RefreshQuickReadUseCase(this._repository);

  final QuickReadRepository _repository;

  /// Devuelve [items] actualizados; saca los animales que ya no están activos.
  Future<Result<List<QuickReadItem>>> call(List<QuickReadItem> items) async {
    final refreshed = <QuickReadItem>[];
    for (final item in items) {
      final result = switch (item) {
        RegisteredRead(:final animal) => await _repository.getAnimal(animal.animal.id),
        UnregisteredRead(:final rfidTagNumber) => await _repository.findByTag(rfidTagNumber),
      };
      if (result is Failure<QuickReadAnimal?>) {
        return Result.failure(result.error);
      }
      final animal = (result as Success<QuickReadAnimal?>).data;
      if (animal != null) {
        refreshed.add(RegisteredRead(animal));
      } else if (item is UnregisteredRead) {
        refreshed.add(item);
      }
    }
    return Result.success(refreshed);
  }
}

/// Establecimientos del usuario.
class GetQuickReadEstablishmentsUseCase {
  /// Crea el caso de uso.
  const GetQuickReadEstablishmentsUseCase(this._repository);

  final QuickReadRepository _repository;

  /// Devuelve las membresías del catálogo offline.
  Future<Result<List<EstablishmentMembership>>> call() => _repository.getEstablishments();
}
