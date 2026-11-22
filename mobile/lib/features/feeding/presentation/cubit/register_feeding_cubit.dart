import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';

part 'register_feeding_cubit.freezed.dart';
part 'register_feeding_state.dart';

/// Coordina el formulario: animales leídos, alimento, lugar, cantidad y fechas.
class RegisterFeedingCubit extends Cubit<RegisterFeedingState> {
  /// Crea el cubit con sus casos de uso.
  RegisterFeedingCubit({
    required PrepareFeedingFormUseCase prepare,
    required ResolveFeedingTagUseCase resolveTag,
    required RegisterFeedingUseCase register,
    DateTime Function()? now,
  }) : _prepare = prepare,
       _resolveTag = resolveTag,
       _register = register,
       _now = now ?? DateTime.now,
       super(const RegisterFeedingState());

  final PrepareFeedingFormUseCase _prepare;
  final ResolveFeedingTagUseCase _resolveTag;
  final RegisterFeedingUseCase _register;
  final DateTime Function() _now;

  /// Carga el formulario con [animalIds]. El potrero arranca en el que
  /// comparten todos los animales, si comparten uno.
  Future<void> start(List<String> animalIds) async {
    emit(state.copyWith(preparation: const ResultState.loading()));
    final result = await _prepare(animalIds);
    if (isClosed) return;
    switch (result) {
      case Success<FeedingFormData>(:final data):
        final lotIds = data.animals.map((a) => a.lotId).toSet();
        final commonLot = lotIds.length == 1 && lotIds.single.isNotEmpty ? lotIds.single : null;
        emit(
          state.copyWith(
            preparation: ResultState.data(data),
            establishmentId: data.establishmentId,
            animals: data.animals,
            lots: data.lots,
            foods: data.foods,
            lotId: data.lots.any((lot) => lot.id == commonLot) ? commonLot : null,
            startDate: _today(),
          ),
        );
      case Failure<FeedingFormData>(:final error):
        emit(state.copyWith(preparation: ResultState.error(error)));
    }
  }

  /// Suma el animal de la caravana leída. Devuelve false si no se pudo.
  Future<bool> addTag(String tag) async {
    emit(state.copyWith(tagResolution: const ResultState.loading()));
    final result = await _resolveTag(tag, establishmentId: state.establishmentId);
    if (isClosed) return false;
    switch (result) {
      case Success<FeedingAnimal>(data: final animal):
        if (state.animals.any((a) => a.id == animal.id)) {
          emit(
            state.copyWith(
              tagResolution: const ResultState.error(
                DomainException(message: 'Ese animal ya está en la lista.', code: DomainErrorCode.conflict),
              ),
            ),
          );
          return false;
        }
        emit(state.copyWith(animals: [...state.animals, animal], tagResolution: const ResultState.initial()));
        return true;
      case Failure<FeedingAnimal>(:final error):
        emit(state.copyWith(tagResolution: ResultState.error(error)));
        return false;
    }
    return false;
  }

  /// Quita un animal de la lista.
  void remove(String animalId) => emit(state.copyWith(animals: state.animals.where((a) => a.id != animalId).toList()));

  /// Suplemento o dieta.
  void selectType(FeedingType type) => emit(state.copyWith(type: type));

  /// Alimento del catálogo; propone su unidad.
  void selectFood(String foodId) {
    final food = state.foods.where((f) => f.id == foodId).firstOrNull;
    emit(state.copyWith(foodId: foodId, newFood: null, unitCode: food?.unitCode ?? state.unitCode));
  }

  /// Alimento nuevo dado de alta en el diálogo.
  void useNewFood(NewFoodInput food) => emit(state.copyWith(newFood: food, foodId: null, unitCode: food.unitCode));

  /// Potrero del suministro; null = corral o manga.
  void selectLot(String? lotId) => emit(state.copyWith(lotId: lotId));

  /// Unidad de la cantidad.
  void selectUnit(String unitCode) => emit(state.copyWith(unitCode: unitCode));

  /// Por animal o por grupo.
  void selectBasis(FeedingQuantityBasis basis) => emit(state.copyWith(basis: basis));

  /// Un día, período o en curso.
  void selectDuration(FeedingDuration duration) => emit(
    state.copyWith(
      duration: duration,
      endDate: duration == FeedingDuration.period ? state.endDate ?? state.startDate : null,
    ),
  );

  /// Fecha de inicio (o la única fecha).
  void selectStart(DateTime date) {
    final end = state.endDate;
    emit(state.copyWith(startDate: date, endDate: end != null && end.isBefore(date) ? date : end));
  }

  /// Fecha de fin del período.
  void selectEnd(DateTime date) => emit(state.copyWith(endDate: date));

  /// Valida y guarda en el celular.
  Future<void> submit({required String quantityText, required String reason}) async {
    if (state.isSaving) return;
    emit(state.copyWith(submission: const ResultState.loading()));
    final start = state.startDate ?? _today();
    final result = await _register(
      establishmentId: state.establishmentId,
      type: state.type,
      animalIds: [for (final animal in state.animals) animal.id],
      foodId: state.foodId,
      newFood: state.newFood,
      lotId: state.lotId,
      quantityText: quantityText,
      unitCode: state.unitCode,
      basis: state.basis,
      startDate: start,
      endDate: switch (state.duration) {
        FeedingDuration.oneDay => start,
        FeedingDuration.period => state.endDate,
        FeedingDuration.ongoing => null,
      },
      reason: reason,
    );
    if (isClosed) return;
    switch (result) {
      case Success<int>(:final data):
        emit(state.copyWith(submission: ResultState.data(data)));
      case Failure<int>(:final error):
        emit(state.copyWith(submission: ResultState.error(error)));
    }
  }

  DateTime _today() {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }
}
