import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';

part 'health_registration_cubit.freezed.dart';

/// Estado local del formulario y de los guardados independientes.
@freezed
sealed class HealthRegistrationState with _$HealthRegistrationState {
  /// Crea un formulario aún sin preparar.
  const factory HealthRegistrationState({
    @Default([]) List<EstablishmentMembership> establishments,
    @Default([]) List<HealthRecipient> recipients,
    String? establishmentId,
    HealthCatalog? catalog,
    @Default(ResultState<void>.initial()) ResultState<void> preparation,
    @Default(ResultState<void>.initial()) ResultState<void> submission,
    String? selectionMessage,
    @Default(0) int pendingReadings,
  }) = _HealthRegistrationState;
}

/// Mantiene el formulario común a los tres puntos de entrada.
class HealthRegistrationCubit extends Cubit<HealthRegistrationState> {
  /// Crea el estado y sus casos de uso.
  HealthRegistrationCubit({
    required ReadHealthUseCase reader,
    required RegisterHealthEventsUseCase register,
    required Future<List<EstablishmentMembership>> Function() establishments,
  }) : _reader = reader,
       _register = register,
       _establishments = establishments,
       super(const HealthRegistrationState());

  final ReadHealthUseCase _reader;
  final RegisterHealthEventsUseCase _register;
  final Future<List<EstablishmentMembership>> Function() _establishments;
  int _preparation = 0;
  Future<void> _readingTail = Future.value();

  /// Carga el establecimiento y vuelve a resolver los UUID preseleccionados.
  Future<void> prepare(String? requestedId, {List<String> animalIds = const [], List<HealthRecipient>? draft}) async {
    final attempt = ++_preparation;
    emit(state.copyWith(preparation: const ResultState.loading()));
    try {
      final choices = await _establishments();
      final id = requestedId ?? (choices.length == 1 ? choices.single.id : null);
      final catalog = id == null ? null : await _reader.catalog(id);
      final selection = id == null ? const <HealthRecipient>[] : await _reader.recipients(id, animalIds);
      if (isClosed || attempt != _preparation) return;
      final references = {
        for (final recipient in draft ?? const <HealthRecipient>[]) recipient.animalId: recipient.sampleReference,
      };
      emit(
        state.copyWith(
          establishmentId: id,
          establishments: choices,
          catalog: catalog,
          recipients: [
            for (final entry in selection) entry.copyWith(sampleReference: references[entry.animalId]),
          ],
          preparation: const ResultState.data(null),
          selectionMessage: selection.length == animalIds.toSet().length
              ? null
              : HealthRegistrationStrings.unavailableAnimal,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      if (isClosed || attempt != _preparation) return;
      emit(state.copyWith(preparation: ResultState.error(healthFormError(error))));
    }
  }

  /// Quita un animal de la confirmación.
  void remove(String id) => emit(
    state.copyWith(
      recipients: state.recipients.where((animal) => animal.animalId != id).toList(),
    ),
  );

  /// Guarda la referencia opcional de un animal seleccionado.
  void updateSampleReference(String id, String reference) {
    final value = reference.trim();
    emit(
      state.copyWith(
        recipients: [
          for (final animal in state.recipients)
            animal.animalId == id ? animal.copyWith(sampleReference: value.isEmpty ? null : value) : animal,
        ],
      ),
    );
  }

  /// Agrega una caravana y procesa las lecturas consecutivas en orden.
  Future<void> addReading(String tag, {required bool electronic}) {
    final id = state.establishmentId;
    if (id == null || state.submission is Loading<void>) return Future.value();
    emit(state.copyWith(pendingReadings: state.pendingReadings + 1));
    return _readingTail = _readingTail.then((_) async {
      if (isClosed) return;
      try {
        final recipient = await _reader.find(id, tag, electronic: electronic);
        if (isClosed || state.establishmentId != id) return;
        if (recipient == null) throw const HealthFailure(HealthProblem.unavailableAnimal);
        if (state.recipients.any((item) => item.animalId == recipient.animalId)) {
          emit(state.copyWith(selectionMessage: HealthRegistrationStrings.duplicate));
          return;
        }
        emit(state.copyWith(recipients: [...state.recipients, recipient], selectionMessage: null));
      } on Object catch (error, stackTrace) {
        addError(error, stackTrace);
        if (!isClosed && state.establishmentId == id) {
          emit(state.copyWith(selectionMessage: healthFormError(error).message));
        }
      } finally {
        if (!isClosed) emit(state.copyWith(pendingReadings: state.pendingReadings - 1));
      }
    });
  }

  /// Confirma los animales revisados en un solo guardado.
  Future<void> submit(HealthRegistration registration, {String? replacingOperationId}) async {
    if (state.submission is Loading<void> || state.submission is Data<void> || state.pendingReadings != 0) return;
    emit(state.copyWith(submission: const ResultState.loading()));
    try {
      await _register(registration, replacingOperationId: replacingOperationId);
      if (!isClosed) emit(state.copyWith(submission: const ResultState.data(null)));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) emit(state.copyWith(submission: ResultState.error(healthFormError(error))));
    }
  }
}

/// Traduce los rechazos de dominio y errores locales para una pantalla.
DomainException healthFormError(Object error) => DomainException(
  message: switch (error) {
    HealthFailure(:final problem) => switch (problem) {
      HealthProblem.unauthorized => HealthRegistrationStrings.unauthorized,
      HealthProblem.catalogUnavailable => HealthRegistrationStrings.catalogUnavailable,
      HealthProblem.unavailablePractice => HealthRegistrationStrings.unavailablePractice,
      HealthProblem.invalidDetails => HealthRegistrationStrings.invalidDetails,
      HealthProblem.invalidSelection => HealthRegistrationStrings.invalidSelection,
      HealthProblem.unavailableAnimal => HealthRegistrationStrings.unavailableAnimal,
      HealthProblem.invalidTag => HealthRegistrationStrings.invalidTag,
      HealthProblem.ambiguousTag => HealthRegistrationStrings.ambiguousTag,
      HealthProblem.invalidResult => HealthRegistrationStrings.invalidResult,
    },
    _ => HealthRegistrationStrings.failed,
  },
);
