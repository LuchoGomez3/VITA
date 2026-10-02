import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/identification/rfid_tag_validator.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';

/// Agrega a la venta un animal activo encontrado en el inventario local.
class AddAnimalToLivestockSaleSelectionUseCase {
  /// Crea el caso de uso con su acceso local y la regla comun de RFID.
  const AddAnimalToLivestockSaleSelectionUseCase({
    required LivestockSaleAnimalRepository repository,
    RfidTagValidator rfidTagValidator = const RfidTagValidator(),
  }) : _repository = repository,
       _rfidTagValidator = rfidTagValidator;

  final LivestockSaleAnimalRepository _repository;
  final RfidTagValidator _rfidTagValidator;

  /// Valida la caravana y devuelve una nueva seleccion si puede incorporarse.
  Future<Result<LivestockSaleSelection>> call({
    required String rfidTagNumber,
    required String establishmentId,
    required LivestockSaleSelection selection,
  }) async {
    if (!_rfidTagValidator(rfidTagNumber)) {
      return _failure(
        LivestockSaleSelectionError.invalidRfid,
        DomainErrorCode.validation,
      );
    }

    final lookup = await _repository.findLocalByRfidTagNumber(rfidTagNumber);
    return lookup.when(
      failure: Result.failure,
      success: (animal) => _addAnimal(
        animal: animal,
        establishmentId: establishmentId,
        selection: selection,
      ),
    );
  }

  Result<LivestockSaleSelection> _addAnimal({
    required LivestockSaleAnimal? animal,
    required String establishmentId,
    required LivestockSaleSelection selection,
  }) {
    if (animal == null) {
      return _failure(
        LivestockSaleSelectionError.animalNotFound,
        DomainErrorCode.notFound,
      );
    }
    if (animal.establishmentId != establishmentId) {
      return _failure(
        LivestockSaleSelectionError.differentEstablishment,
        DomainErrorCode.validation,
      );
    }

    final statusError = _statusError(animal.status);
    if (statusError != null) {
      return _failure(statusError, DomainErrorCode.conflict);
    }
    if (selection.animals.any((selected) => selected.id == animal.id)) {
      return _failure(
        LivestockSaleSelectionError.duplicateAnimal,
        DomainErrorCode.conflict,
      );
    }

    return Result.success(
      selection.copyWith(animals: [...selection.animals, animal]),
    );
  }

  LivestockSaleSelectionError? _statusError(
    LivestockSaleAnimalStatus status,
  ) {
    return switch (status) {
      LivestockSaleAnimalStatus.active => null,
      LivestockSaleAnimalStatus.sold => LivestockSaleSelectionError.animalSold,
      LivestockSaleAnimalStatus.dead => LivestockSaleSelectionError.animalDead,
      LivestockSaleAnimalStatus.removed => LivestockSaleSelectionError.animalRemoved,
      LivestockSaleAnimalStatus.unknown => LivestockSaleSelectionError.animalStatusUnknown,
    };
  }

  Result<LivestockSaleSelection> _failure(
    LivestockSaleSelectionError reason,
    DomainErrorCode code,
  ) {
    return Result.failure(
      DomainException(message: reason.name, code: code, reason: reason),
    );
  }
}
