import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_category.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/check_animal_rfid_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_categories_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/get_animal_parents_use_case.dart';
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
  /// establecimiento y lote. Mantenerlo como abstraccion
  /// evita que presentation dependa de implementaciones concretas de data.
  RegisterAnimalBloc({
    required RegisterAnimalUseCase registerAnimalUseCase,
    required GetAnimalCategoriesUseCase getAnimalCategoriesUseCase,
    required GetAnimalParentsUseCase getAnimalParentsUseCase,
    required CheckAnimalRfidUseCase checkAnimalRfidUseCase,
    required AnimalRegistrationContext registrationContext,
    RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
    String initialRfid = '',
    String? initialEstablishmentId,
  }) : _registerAnimalUseCase = registerAnimalUseCase,
       _getAnimalCategoriesUseCase = getAnimalCategoriesUseCase,
       _getAnimalParentsUseCase = getAnimalParentsUseCase,
       _checkAnimalRfidUseCase = checkAnimalRfidUseCase,
       _registrationContext = registrationContext,
       super(
         RegisterAnimalState(
           currentStep: initialStep,
           draft: RegisterAnimalDraft.initial(rfid: initialRfid).copyWith(
             establishmentId: initialEstablishmentId,
           ),
         ),
       ) {
    on<_DraftChanged>(_onDraftChanged);
    on<_RfidCaptured>(_onRfidCaptured);
    on<_CategoriesRequested>(_onCategoriesRequested);
    on<_ParentsRequested>(_onParentsRequested);
    on<_EstablishmentsRequested>(_onEstablishmentsRequested);
    on<_EstablishmentSelected>(_onEstablishmentSelected);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_StepRequested>(_onStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final RegisterAnimalUseCase _registerAnimalUseCase;
  final GetAnimalCategoriesUseCase _getAnimalCategoriesUseCase;
  final GetAnimalParentsUseCase _getAnimalParentsUseCase;
  final CheckAnimalRfidUseCase _checkAnimalRfidUseCase;
  final AnimalRegistrationContext _registrationContext;
  int _parentsRequest = 0;

  Future<void> _onParentsRequested(
    _ParentsRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    final establishmentId = state.draft.establishmentId;
    if (establishmentId == null) return;
    final request = ++_parentsRequest;
    emit(state.copyWith(parentsState: const ResultState.loading()));
    final result = await _getAnimalParentsUseCase(establishmentId);
    // Un cambio de establecimiento invalida cualquier lectura anterior.
    if (request != _parentsRequest) return;
    switch (result) {
      case Success<List<AnimalParent>>(:final data):
        emit(state.copyWith(parentsState: ResultState.data(data)));
      case Failure<List<AnimalParent>>(:final error):
        emit(state.copyWith(parentsState: ResultState.error(error)));
    }
  }

  Future<void> _onCategoriesRequested(
    _CategoriesRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    emit(state.copyWith(categoriesState: const ResultState.loading()));
    final result = await _getAnimalCategoriesUseCase();
    switch (result) {
      case Success<List<AnimalCategory>>(:final data):
        emit(
          state.copyWith(
            categoriesState: ResultState.data(data),
          ),
        );
      case Failure<List<AnimalCategory>>(:final error):
        emit(state.copyWith(categoriesState: ResultState.error(error)));
    }
  }

  Future<void> _onEstablishmentsRequested(
    _EstablishmentsRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    emit(state.copyWith(establishmentsState: const ResultState.loading()));
    try {
      final establishments = await _registrationContext.loadEstablishments();
      final requestedId = state.draft.establishmentId;
      final requested = establishments.where(
        (establishment) => establishment.id == requestedId,
      );
      final selected = requested.isNotEmpty
          ? requested.first
          : establishments.length == 1
          ? establishments.first
          : null;
      emit(
        state.copyWith(
          establishmentsState: ResultState.data(establishments),
          destinationsState: const ResultState.initial(),
          draft: state.draft.copyWith(
            establishmentId: selected?.id,
            establishmentName: selected?.name,
            destinationId: null,
          ),
        ),
      );
      if (selected != null) {
        add(RegisterAnimalEvent.establishmentSelected(selected.id));
      }
    } on Object {
      emit(
        state.copyWith(
          establishmentsState: const ResultState.error(
            DomainException(
              message: AnimalRegisterStrings.establishmentsLoadError,
              code: DomainErrorCode.offline,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onEstablishmentSelected(
    _EstablishmentSelected event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    final establishment = state.establishments.where((item) => item.id == event.establishmentId).firstOrNull;
    if (establishment == null) {
      return;
    }

    _parentsRequest++;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          establishmentId: establishment.id,
          establishmentName: establishment.name,
          destinationId: null,
          mother: null,
          father: null,
        ),
        parentsState: const ResultState.initial(),
        destinationsState: const ResultState.loading(),
      ),
    );
    add(const RegisterAnimalEvent.parentsRequested());
    try {
      final destinations = await _registrationContext.loadDestinations(
        establishment.id,
      );
      if (state.draft.establishmentId != establishment.id) return;
      emit(state.copyWith(destinationsState: ResultState.data(destinations)));
    } on Object {
      if (state.draft.establishmentId != establishment.id) return;
      emit(
        state.copyWith(
          destinationsState: const ResultState.error(
            DomainException(
              message: AnimalRegisterStrings.destinationsLoadError,
              code: DomainErrorCode.offline,
            ),
          ),
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
    emit(
      state.copyWith(
        draft: event.draft,
        rfidCheckState: event.draft.rfid == state.draft.rfid ? state.rfidCheckState : const ResultState.initial(),
      ),
    );
  }

  Future<void> _onRfidCaptured(
    _RfidCaptured event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(rfid: event.rfid),
        rfidCheckState: const ResultState.loading(),
      ),
    );
    await _checkRfid(event.rfid, emit);
  }

  Future<bool> _checkRfid(String rfid, Emitter<RegisterAnimalState> emit) async {
    if (!_isValidRfid(rfid)) {
      emit(
        state.copyWith(
          rfidCheckState: const ResultState.error(
            DomainException(message: AnimalRegisterStrings.rfidInvalid, code: DomainErrorCode.validation),
          ),
        ),
      );
      return false;
    }
    emit(state.copyWith(rfidCheckState: const ResultState.loading()));
    final result = await _checkAnimalRfidUseCase(rfid);
    if (state.draft.rfid.trim() != rfid) return false;
    switch (result) {
      case Success<bool>(:final data):
        emit(state.copyWith(rfidCheckState: ResultState.data(data)));
        return !data;
      case Failure<bool>(:final error):
        emit(state.copyWith(rfidCheckState: ResultState.error(error)));
        return false;
    }
    return false;
  }

  /// Avanza el wizard un paso, sin pasar de la pantalla de revision.
  Future<void> _onNextStepRequested(
    _NextStepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    final currentStep = state.currentStep;
    if (currentStep == RegisterAnimalStep.review || state.rfidCheckState is Loading<bool>) {
      return;
    }

    if (currentStep == RegisterAnimalStep.identification && !await _checkRfid(state.draft.rfid.trim(), emit)) {
      return;
    }

    if (state.currentStep != currentStep) return;

    emit(
      state.copyWith(
        currentStep: RegisterAnimalStep.values[currentStep.index + 1],
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

    if (!await _checkRfid(state.draft.rfid.trim(), emit)) {
      final error = switch (state.rfidCheckState) {
        ResultError<bool>(:final error) => error,
        _ => const DomainException(
          message: AnimalRegisterStrings.rfidAlreadyRegistered,
          code: DomainErrorCode.validation,
        ),
      };
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
          message: AnimalRegisterStrings.rfidInvalid,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final establishmentId = draft.establishmentId;
    if (establishmentId == null) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.establishmentRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final destinationId = draft.destinationId;
    if (destinationId == null) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.destinationRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final breed = draft.breed.trim();
    if (breed.isEmpty) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.breedRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    if (draft.sex.isEmpty) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.sexRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final birthDate = draft.birthDate;
    if (birthDate == null) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.birthDateRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final categoryId = draft.categoryId;
    final categoryName = draft.categoryName;
    if (categoryId == null || categoryName == null) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.categoryRequired,
          code: DomainErrorCode.validation,
        ),
      );
    }

    final parsedWeight = _parseWeight(draft.birthWeight);
    if (parsedWeight == null || parsedWeight <= 0) {
      return const Result.failure(
        DomainException(
          message: AnimalRegisterStrings.invalidBirthWeight,
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
          breed: breed,
          birthDate: birthDate,
          lotId: _registrationContext.resolveLotId(destinationId),
          lotName: _registrationContext.resolveLotName(destinationId),
          establishmentId: establishmentId,
          categoryId: categoryId,
          categoryName: categoryName,
          initialWeight: parsedWeight,
          motherId: draft.mother?.id,
          fatherId: draft.father?.id,
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
