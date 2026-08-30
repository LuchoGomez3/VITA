import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

part 'register_animal_bloc.freezed.dart';
part 'register_animal_event.dart';
part 'register_animal_state.dart';

/// Coordina el wizard de registro de animal.
///
/// Este BLoC solo maneja estado de presentacion: el paso visual actual, el
/// borrador que se va completando y el resultado que la UI debe mostrar. El
/// guardado offline-first real se delega a [RegisterAnimalUseCase].
class RegisterAnimalBloc extends Bloc<RegisterAnimalEvent, RegisterAnimalState> {
  /// Crea el BLoC de registro en el paso inicial solicitado.
  ///
  /// [registrationContext] es un contrato de dominio que resuelve IDs de
  /// establecimiento, lote, categoria y genealogia. Mantenerlo como abstraccion
  /// evita que presentation dependa de implementaciones concretas de data.
  RegisterAnimalBloc({
    required RegisterAnimalUseCase registerAnimalUseCase,
    required AnimalRegistrationContext registrationContext,
    RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
    String initialRfid = '',
  }) : _registerAnimalUseCase = registerAnimalUseCase,
       _registrationContext = registrationContext,
       super(
         RegisterAnimalState(
           currentStep: initialStep,
           draft: RegisterAnimalDraft.initial(rfid: initialRfid),
         ),
       ) {
    on<_DraftChanged>(_onDraftChanged);
    on<_DestinationsRequested>(_onDestinationsRequested);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_StepRequested>(_onStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final RegisterAnimalUseCase _registerAnimalUseCase;
  final AnimalRegistrationContext _registrationContext;

  Future<void> _onDestinationsRequested(
    _DestinationsRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingDestinations: true,
        destinationsError: null,
      ),
    );
    try {
      final destinations = await _registrationContext.loadDestinations();
      final selectedId = state.draft.destinationId;
      final selectionStillExists = destinations.any(
        (destination) => destination.id == selectedId,
      );
      emit(
        state.copyWith(
          destinations: destinations,
          isLoadingDestinations: false,
          draft: selectionStillExists ? state.draft : state.draft.copyWith(destinationId: null),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isLoadingDestinations: false,
          destinationsError: 'No se pudieron cargar los lotes guardados.',
        ),
      );
    }
  }

  /// Reemplaza el borrador completo cuando un campo del formulario cambia.
  ///
  /// Los widgets de cada paso mantienen la logica simple: mandan una copia del
  /// draft actualizado en vez de tener un evento diferente por cada input.
  void _onDraftChanged(
    _DraftChanged event,
    Emitter<RegisterAnimalState> emit,
  ) {
    emit(state.copyWith(draft: event.draft));
  }

  /// Avanza el wizard un paso, sin pasar de la pantalla de revision.
  void _onNextStepRequested(
    _NextStepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    if (state.currentStep == RegisterAnimalStep.review) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterAnimalStep.values[state.currentStep.index + 1],
      ),
    );
  }

  /// Retrocede el wizard un paso, sin volver antes de identificacion.
  void _onPreviousStepRequested(
    _PreviousStepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    if (state.currentStep == RegisterAnimalStep.identification) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterAnimalStep.values[state.currentStep.index - 1],
      ),
    );
  }

  /// Salta a un paso especifico cuando la UI pide navegacion directa.
  void _onStepRequested(
    _StepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  /// Valida el borrador, construye el request de dominio y lo envia.
  ///
  /// El repository detras del use case guarda primero localmente con Brick. Por
  /// eso, un resultado exitoso significa "persistido en este dispositivo y
  /// encolado/programado para sincronizar", no necesariamente aceptado ya por
  /// el backend.
  Future<void> _onSubmitRequested(
    _SubmitRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    if (state.submitResult is Loading<RegisteredAnimal>) {
      return;
    }

    final registration = _buildRegistration();
    if (registration case Failure<AnimalRegistration>(:final error)) {
      emit(state.copyWith(submitResult: ResultState.error(error)));
      return;
    }

    emit(state.copyWith(submitResult: const ResultState.loading()));

    final result = await _registerAnimalUseCase(
      (registration as Success<AnimalRegistration>).data,
    );

    switch (result) {
      case Success<RegisteredAnimal>(:final data):
        emit(state.copyWith(submitResult: ResultState.data(data)));
      case Failure<RegisteredAnimal>(:final error):
        emit(state.copyWith(submitResult: ResultState.error(error)));
    }
  }

  /// Construye el request de dominio a partir del draft de presentacion.
  ///
  /// Esta es la frontera donde labels de UI y valores del formulario se
  /// normalizan al modelo de dominio. El contexto provee IDs listos para backend
  /// sin exponer fuentes de datos concretas al BLoC.
  Result<AnimalRegistration> _buildRegistration() {
    // TODO(agustin): Extract this transformation/validation flow out of the
    // bloc. Presentation should trigger the use case, not assemble the full
    // registration payload with business-context resolution.
    final draft = state.draft;
    final rfid = draft.rfid.trim();
    if (!_isValidRfid(rfid)) {
      return const Result.failure(
        DomainException(
          message: 'Ingresá una caravana RFID válida de 15 dígitos.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final destinationId = draft.destinationId;
    if (destinationId == null) {
      return const Result.failure(
        DomainException(
          message: 'Seleccioná el potrero de destino antes de guardar.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final parsedWeight = _parseWeight(draft.birthWeight);
    if (parsedWeight == null || parsedWeight <= 0) {
      return const Result.failure(
        DomainException(
          message: 'Ingresá un peso válido mayor a 0 kg.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    // La caravana visual es opcional en UI y esta dividida en dos campos; para
    // dominio/backend se trabaja como un unico valor de visualizacion.
    final visualTag = [
      draft.visualTagSeries.trim(),
      draft.visualTagNumber.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    try {
      return Result.success(
        AnimalRegistration(
          rfidTagNumber: rfid,
          visualTag: visualTag,
          sex: _mapSex(draft.sex),
          breed: draft.breed,
          birthDate: draft.birthDate,
          lotId: _registrationContext.resolveLotId(destinationId),
          lotName: _registrationContext.resolveLotName(destinationId),
          establishmentId: _registrationContext.establishmentId,
          categoryId: _registrationContext.resolveCategoryId(draft.category),
          categoryName: draft.category,
          initialWeight: parsedWeight,
          motherId: _registrationContext.resolveMotherId(draft.motherId),
          fatherId: _registrationContext.resolveFatherId(draft.fatherId),
          weighingDate: DateTime.now().toUtc(),
        ),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    }
  }

  /// Valida el formato RFID compatible con SENASA usado por el formulario.
  bool _isValidRfid(String value) {
    return RegExp(r'^\d{15}$').hasMatch(value);
  }

  /// Parsea kilos ingresados por el usuario, aceptando coma o punto decimal.
  double? _parseWeight(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  /// Mapea la opcion localizada de UI al enum de dominio.
  AnimalSex _mapSex(String value) {
    return value == AnimalRegisterStrings.stepTwoMale ? AnimalSex.male : AnimalSex.female;
  }
}
