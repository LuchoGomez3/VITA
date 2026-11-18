import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/repositories/feeding_repositories.dart';

/// Historial de alimentación de un animal para la ficha.
class GetAnimalFeedingHistoryUseCase {
  /// Crea el caso de uso.
  const GetAnimalFeedingHistoryUseCase(this._repository);

  final FeedingHistoryRepository _repository;

  /// Cambios persistidos que requieren releer el historial.
  Stream<void> get changes => _repository.changes;

  /// Devuelve el historial de [animalId].
  Future<Result<AnimalFeedingHistory>> call(String animalId) => _repository.getAnimalHistory(animalId);
}

/// Lo que necesita el formulario para arrancar.
class FeedingFormData {
  /// Crea los datos iniciales.
  const FeedingFormData({
    required this.establishmentId,
    required this.animals,
    required this.lots,
    required this.foods,
  });

  /// Establecimiento de los animales iniciales.
  final String establishmentId;

  /// Animales con los que arranca el formulario.
  final List<FeedingAnimal> animals;

  /// Potreros vigentes.
  final List<FeedingLot> lots;

  /// Catálogo de alimentos.
  final List<Food> foods;
}

/// Prepara el formulario a partir de los animales iniciales.
class PrepareFeedingFormUseCase {
  /// Crea el caso de uso.
  const PrepareFeedingFormUseCase(this._repository);

  final FeedingRegisterRepository _repository;

  /// Carga animales, potreros y alimentos desde el celular.
  Future<Result<FeedingFormData>> call(List<String> animalIds) async {
    final animals = <FeedingAnimal>[];
    for (final id in animalIds) {
      final result = await _repository.getAnimal(id);
      if (result case Failure(:final error)) return Result.failure(error);
      if ((result as Success<FeedingAnimal?>).data case final animal?) animals.add(animal);
    }
    if (animals.isEmpty) {
      return const Result.failure(
        DomainException(message: 'El animal no está disponible en este celular.', code: DomainErrorCode.notFound),
      );
    }
    final establishmentId = animals.first.establishmentId;
    final lots = await _repository.getLots(establishmentId);
    if (lots case Failure(:final error)) return Result.failure(error);
    final foods = await _repository.getFoods(establishmentId);
    if (foods case Failure(:final error)) return Result.failure(error);
    return Result.success(
      FeedingFormData(
        establishmentId: establishmentId,
        animals: animals,
        lots: (lots as Success<List<FeedingLot>>).data,
        foods: (foods as Success<List<Food>>).data,
      ),
    );
  }
}

/// Busca un animal por la caravana leída o tipeada.
class ResolveFeedingTagUseCase {
  /// Crea el caso de uso.
  const ResolveFeedingTagUseCase(this._repository);

  final FeedingRegisterRepository _repository;

  /// Devuelve el animal o un error legible si no está.
  Future<Result<FeedingAnimal>> call(String tag, {required String establishmentId}) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(
        DomainException(message: 'Leé o escribí una caravana.', code: DomainErrorCode.validation),
      );
    }
    final result = await _repository.findAnimalByTag(trimmed, establishmentId: establishmentId);
    if (result case Failure(:final error)) return Result.failure(error);
    final animal = (result as Success<FeedingAnimal?>).data;
    if (animal == null) {
      return Result.failure(
        DomainException(message: 'No hay un animal con la caravana $trimmed.', code: DomainErrorCode.notFound),
      );
    }
    return Result.success(animal);
  }
}

/// Alimento nuevo dado de alta desde el formulario.
class NewFoodInput {
  /// Crea los datos del alimento.
  const NewFoodInput({required this.name, required this.categoryCode, required this.unitCode});

  /// Nombre visible.
  final String name;

  /// Código de categoría.
  final String categoryCode;

  /// Unidad por defecto.
  final String unitCode;
}

/// Registra un suplemento o dieta para uno o varios animales.
///
/// Valida en el celular lo mismo que backend para no encolar algo que el
/// servidor va a rechazar.
class RegisterFeedingUseCase {
  /// Crea el caso de uso con generador de UUID y reloj inyectables.
  RegisterFeedingUseCase({
    required FeedingRegisterRepository repository,
    required String Function() createId,
    DateTime Function()? now,
  }) : _repository = repository,
       _createId = createId,
       _now = now ?? DateTime.now;

  final FeedingRegisterRepository _repository;
  final String Function() _createId;
  final DateTime Function() _now;

  /// Máximo de animales por registro (igual que backend).
  static const maxAnimals = 500;

  /// Guarda el registro. Usa [foodId] o, si viene [newFood], lo da de alta.
  Future<Result<int>> call({
    required String establishmentId,
    required FeedingType type,
    required List<String> animalIds,
    required String quantityText,
    required String unitCode,
    required FeedingQuantityBasis basis,
    required DateTime startDate,
    String? foodId,
    NewFoodInput? newFood,
    String? lotId,
    DateTime? endDate,
    String? reason,
  }) async {
    final today = _day(_now());
    final start = _day(startDate);
    final end = endDate == null ? null : _day(endDate);
    final quantity = num.tryParse(quantityText.trim().replaceAll(',', '.'));

    if (animalIds.isEmpty) return _invalid('Agregá al menos un animal.');
    if (animalIds.length > maxAnimals) return _invalid('Se pueden registrar hasta $maxAnimals animales juntos.');
    if (foodId == null && newFood == null) return _invalid('Elegí un alimento.');
    if (newFood != null && newFood.name.trim().isEmpty) return _invalid('Escribí el nombre del alimento.');
    if (quantity == null || quantity <= 0) return _invalid('Ingresá una cantidad mayor a 0.');
    if (start.isAfter(today)) return _invalid('La fecha de inicio no puede ser futura.');
    if (end != null && end.isBefore(start)) return _invalid('La fecha de fin no puede ser anterior a la de inicio.');

    final timestamp = _now().toUtc();
    final food = newFood == null
        ? null
        : Food(
            id: _createId(),
            name: newFood.name.trim(),
            categoryCode: newFood.categoryCode,
            unitCode: newFood.unitCode,
          );
    final trimmedReason = reason?.trim();
    final record = FeedingRecord(
      id: _createId(),
      establishmentId: establishmentId,
      type: type,
      foodId: food?.id ?? foodId!,
      lotId: lotId,
      startDate: start,
      endDate: end,
      quantity: quantity.toString(),
      unitCode: unitCode,
      basis: basis,
      reason: trimmedReason == null || trimmedReason.isEmpty ? null : trimmedReason,
      animalIds: List.unmodifiable(animalIds.toSet()),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    final result = await _repository.saveRecord(record, newFood: food);
    return switch (result) {
      Success() => Result.success(record.animalIds.length),
      Failure(:final error) => Result.failure(error),
      _ => const Result.failure(DomainException(message: 'No se pudo guardar la alimentación.')),
    };
  }

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  static Result<int> _invalid(String message) =>
      Result.failure(DomainException(message: message, code: DomainErrorCode.validation));
}
