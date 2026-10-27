import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_draft_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/delete_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/load_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/save_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/search_livestock_sale_animals_by_rfid_prefix_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

part 'livestock_sale_bloc.freezed.dart';
part 'livestock_sale_event.dart';
part 'livestock_sale_state.dart';

/// Coordina el borrador y la navegacion del registro offline de una venta.
class LivestockSaleBloc extends Bloc<LivestockSaleEvent, LivestockSaleState> {
  /// Crea el BLoC con los casos de uso resueltos fuera de presentation.
  LivestockSaleBloc({
    required String userId,
    required String establishmentId,
    required AddAnimalToLivestockSaleSelectionUseCase addAnimal,
    required SearchLivestockSaleAnimalsByRfidPrefixUseCase searchAnimalsByRfidPrefix,
    required RemoveAnimalFromLivestockSaleSelectionUseCase removeAnimal,
    required ConfirmLivestockSaleUseCase confirmSale,
    required LoadLivestockSaleDraftUseCase loadDraft,
    required SaveLivestockSaleDraftUseCase saveDraft,
    required DeleteLivestockSaleDraftUseCase deleteDraft,
    DateTime Function()? now,
    Duration draftSaveDebounce = const Duration(milliseconds: 400),
    bool persistDraftOnClose = true,
  }) : _userId = userId,
       _addAnimal = addAnimal,
       _searchAnimalsByRfidPrefix = searchAnimalsByRfidPrefix,
       _removeAnimal = removeAnimal,
       _confirmSale = confirmSale,
       _loadDraft = loadDraft,
       _saveDraft = saveDraft,
       _deleteDraft = deleteDraft,
       _now = now ?? DateTime.now,
       _draftSaveDebounce = draftSaveDebounce,
       _persistDraftOnClose = persistDraftOnClose,
       super(
         LivestockSaleState(
           form: LivestockSaleFormDraft.initial(
             establishmentId: establishmentId,
             today: (now ?? DateTime.now)(),
           ),
         ),
       ) {
    on<_DraftLoadRequested>(_onDraftLoadRequested);
    on<_DraftRestoreAccepted>(_onDraftRestoreAccepted);
    on<_SavedDraftDiscardRequested>(_onSavedDraftDiscardRequested);
    on<_FormChanged>(_onFormChanged);
    on<_AnimalAddRequested>(_onAnimalAddRequested);
    on<_RfidPrefixChanged>(_onRfidPrefixChanged);
    on<_AnimalRemoveRequested>(_onAnimalRemoveRequested);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
    on<_SaveAndExitRequested>(_onSaveAndExitRequested);
    on<_DiscardAndExitRequested>(_onDiscardAndExitRequested);
    add(const LivestockSaleEvent.draftLoadRequested());
  }

  final String _userId;
  final AddAnimalToLivestockSaleSelectionUseCase _addAnimal;
  final SearchLivestockSaleAnimalsByRfidPrefixUseCase _searchAnimalsByRfidPrefix;
  final RemoveAnimalFromLivestockSaleSelectionUseCase _removeAnimal;
  final ConfirmLivestockSaleUseCase _confirmSale;
  final LoadLivestockSaleDraftUseCase _loadDraft;
  final SaveLivestockSaleDraftUseCase _saveDraft;
  final DeleteLivestockSaleDraftUseCase _deleteDraft;
  final DateTime Function() _now;
  final Duration _draftSaveDebounce;
  final bool _persistDraftOnClose;
  Timer? _draftSaveTimer;
  Future<void>? _pendingDraftWrite;

  Future<void> _onDraftLoadRequested(
    _DraftLoadRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    final result = await _loadDraft(
      userId: _userId,
      establishmentId: state.form.establishmentId,
    );
    switch (result) {
      case Success<LivestockSaleSavedDraft?>(:final data):
        emit(
          state.copyWith(
            draftRecoveryStatus: data == null
                ? LivestockSaleDraftRecoveryStatus.ready
                : LivestockSaleDraftRecoveryStatus.choiceRequired,
            savedDraft: data,
          ),
        );
      case Failure<LivestockSaleSavedDraft?>(:final error):
        emit(
          state.copyWith(
            draftRecoveryStatus: LivestockSaleDraftRecoveryStatus.ready,
            draftFeedback: _localizedDraftError(error),
          ),
        );
    }
  }

  Future<void> _onDraftRestoreAccepted(
    _DraftRestoreAccepted event,
    Emitter<LivestockSaleState> emit,
  ) async {
    final savedDraft = state.savedDraft;
    if (savedDraft == null) return;

    var selection = const LivestockSaleSelection();
    var unavailableCount = 0;
    for (final rfid in savedDraft.selectedRfidTagNumbers) {
      final result = await _addAnimal(
        rfidTagNumber: rfid,
        establishmentId: state.form.establishmentId,
        selection: selection,
      );
      switch (result) {
        case Success<LivestockSaleSelection>(:final data):
          selection = data;
        case Failure<LivestockSaleSelection>():
          unavailableCount++;
      }
    }

    final restoredStep = selection.animals.isEmpty
        ? LivestockSaleStep.animals
        : LivestockSaleStep.values[savedDraft.currentStep.index];
    emit(
      state.copyWith(
        form: _formFromSavedDraft(savedDraft),
        selection: selection,
        currentStep: restoredStep,
        animalSelectionResult: ResultState.data(selection),
        draftRecoveryStatus: LivestockSaleDraftRecoveryStatus.ready,
        savedDraft: null,
        hasDraftChanges: true,
        draftFeedback: unavailableCount == 0
            ? null
            : DomainException(
                message: LivestockSaleStrings.unavailableRestoredAnimals(
                  unavailableCount,
                ),
              ),
      ),
    );
    await _persistSnapshot(
      _snapshotFromState(
        state.copyWith(
          form: _formFromSavedDraft(savedDraft),
          selection: selection,
          currentStep: restoredStep,
        ),
      ),
    );
  }

  Future<void> _onSavedDraftDiscardRequested(
    _SavedDraftDiscardRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    final result = await _deleteCurrentDraft();
    final error = result.when<DomainException?>(
      success: (_) => null,
      failure: (failure) => failure,
    );
    emit(
      state.copyWith(
        draftRecoveryStatus: LivestockSaleDraftRecoveryStatus.ready,
        savedDraft: null,
        hasDraftChanges: false,
        draftFeedback: error == null ? null : _localizedDraftError(error),
      ),
    );
  }

  Future<void> _onFormChanged(
    _FormChanged event,
    Emitter<LivestockSaleState> emit,
  ) async {
    // Centralizar la normalizacion aca mantiene iguales los datos aunque el
    // cambio venga de otro widget o de una futura restauracion del borrador.
    final normalizedForm = _normalizeChangedForm(event.form);
    final hasDraftChanges = _hasMeaningfulDraftChanges(
      form: normalizedForm,
      selection: state.selection,
    );
    emit(
      state.copyWith(
        form: normalizedForm,
        hasDraftChanges: hasDraftChanges,
        stepError: null,
      ),
    );
    if (hasDraftChanges) {
      _scheduleDraftSave();
    } else {
      _draftSaveTimer?.cancel();
      await _deleteCurrentDraft();
    }
  }

  Future<void> _onAnimalAddRequested(
    _AnimalAddRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    // Bloquea lecturas paralelas para que dos respuestas no alteren el orden de
    // seleccion ni incorporen dos veces la misma caravana.
    if (state.animalSelectionResult is Loading<LivestockSaleSelection>) return;

    emit(
      state.copyWith(
        animalSelectionResult: const ResultState.loading(),
        stepError: null,
      ),
    );
    final result = await _addAnimal(
      rfidTagNumber: event.rfidTagNumber,
      establishmentId: state.form.establishmentId,
      selection: state.selection,
    );
    switch (result) {
      // El resultado asincrono se guarda separado del borrador del formulario,
      // permitiendo que la pantalla muestre carga o error sin perder seleccion.
      case Success<LivestockSaleSelection>(:final data):
        emit(
          state.copyWith(
            selection: data,
            animalSelectionResult: ResultState.data(data),
            rfidPrefix: '',
            rfidSuggestions: const ResultState.initial(),
            hasDraftChanges: true,
          ),
        );
        await _persistCurrentDraft();
      case Failure<LivestockSaleSelection>(:final error):
        emit(
          state.copyWith(
            animalSelectionResult: ResultState.error(
              _localizedSelectionError(error),
            ),
          ),
        );
    }
  }

  Future<void> _onRfidPrefixChanged(
    _RfidPrefixChanged event,
    Emitter<LivestockSaleState> emit,
  ) async {
    final prefix = event.prefix.trim();
    if (prefix.isEmpty) {
      emit(
        state.copyWith(
          rfidPrefix: '',
          rfidSuggestions: const ResultState.initial(),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        rfidPrefix: prefix,
      ),
    );
    final result = await _searchAnimalsByRfidPrefix(prefix);

    // Una respuesta lenta de un prefijo anterior no debe reemplazar a la
    // búsqueda que el productor está viendo actualmente.
    if (state.rfidPrefix != prefix) return;

    switch (result) {
      case Success<List<LivestockSaleAnimal>>(:final data):
        final selectedAnimalIds = state.selection.animals.map((animal) => animal.id).toSet();
        final availableAnimals = data
            .where(
              (animal) => animal.status == LivestockSaleAnimalStatus.active && !selectedAnimalIds.contains(animal.id),
            )
            .toList(growable: false);
        emit(
          state.copyWith(
            rfidSuggestions: ResultState.data(availableAnimals),
          ),
        );
      case Failure<List<LivestockSaleAnimal>>(:final error):
        emit(state.copyWith(rfidSuggestions: ResultState.error(error)));
    }
  }

  Future<void> _onAnimalRemoveRequested(
    _AnimalRemoveRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    final selection = _removeAnimal(
      animalId: event.animalId,
      selection: state.selection,
    );
    final hasDraftChanges = _hasMeaningfulDraftChanges(
      form: state.form,
      selection: selection,
    );
    emit(
      state.copyWith(
        selection: selection,
        animalSelectionResult: ResultState.data(selection),
        stepError: null,
        hasDraftChanges: hasDraftChanges,
      ),
    );
    if (hasDraftChanges) {
      await _persistCurrentDraft();
    } else {
      _draftSaveTimer?.cancel();
      await _deleteCurrentDraft();
    }
  }

  Future<void> _onNextStepRequested(
    _NextStepRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    if (state.currentStep == LivestockSaleStep.review) return;

    // Cada paso valida solo lo que necesita para avanzar. La operacion completa
    // se convierte a dominio antes de llegar a la pantalla de resumen.
    final error = switch (state.currentStep) {
      LivestockSaleStep.animals =>
        state.selection.animals.isEmpty ? _validationError(LivestockSaleStrings.requiredAnimals) : null,
      LivestockSaleStep.operation => _validateCompleteDraft(),
      LivestockSaleStep.review => null,
    };
    if (error != null) {
      _emitStepError(emit, error);
      return;
    }

    emit(
      state.copyWith(
        currentStep: LivestockSaleStep.values[state.currentStep.index + 1],
        stepError: null,
      ),
    );
    await _persistCurrentDraft();
  }

  Future<void> _onPreviousStepRequested(
    _PreviousStepRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    if (state.currentStep == LivestockSaleStep.animals) return;
    emit(
      state.copyWith(
        currentStep: LivestockSaleStep.values[state.currentStep.index - 1],
        stepError: null,
      ),
    );
    await _persistCurrentDraft();
  }

  Future<void> _onSubmitRequested(
    _SubmitRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    // Confirmar fuera del resumen o repetir el toque durante una escritura se
    // ignora para conservar una unica venta local idempotente.
    if (state.currentStep != LivestockSaleStep.review || state.submitResult is Loading<LivestockSale>) {
      return;
    }

    final draftResult = _buildDomainDraft();
    if (draftResult case Failure<LivestockSaleDraft>(:final error)) {
      _emitStepError(emit, error);
      return;
    }

    emit(
      state.copyWith(
        submitResult: const ResultState.loading(),
        stepError: null,
      ),
    );
    final result = await _confirmSale(
      (draftResult as Success<LivestockSaleDraft>).data,
    );
    switch (result) {
      case Success<LivestockSale>(:final data):
        _draftSaveTimer?.cancel();
        await _deleteCurrentDraft();
        emit(state.copyWith(submitResult: ResultState.data(data)));
      case Failure<LivestockSale>(:final error):
        emit(
          state.copyWith(
            submitResult: ResultState.error(_localizedSaleError(error)),
          ),
        );
    }
  }

  DomainException? _validateCompleteDraft() {
    // Presentation interpreta los textos y dominio aplica las reglas finales;
    // de ese modo no se duplican validaciones comerciales en los widgets.
    final requiredFieldError = _validateRequiredFields();
    if (requiredFieldError != null) return requiredFieldError;
    final result = _buildDomainDraft();
    if (result case Failure<LivestockSaleDraft>(:final error)) return error;
    final draft = (result as Success<LivestockSaleDraft>).data;
    final error = _confirmSale.validate(draft: draft, today: _now());
    return error == null ? null : _saleValidationError(error);
  }

  Result<LivestockSaleDraft> _buildDomainDraft() {
    try {
      final form = state.form;
      int? totalWeightGrams;
      int? pricePerKgMicros;
      late final int totalAmountCents;

      // Todos los decimales se convierten a enteros escalados. No se usa
      // double porque podria cambiar el precio pactado o el centavo truncado.
      if (form.saleType == LivestockSaleType.bulk) {
        final parsedTotal = ScaledDecimalFormatter.tryParse(
          form.bulkTotalAmount,
          2,
        );
        if (parsedTotal == null) {
          return Result.failure(
            _fieldValidationError(
              LivestockSaleFormField.bulkTotalAmount,
              LivestockSaleStrings.saleError(
                LivestockSaleError.invalidTotalAmount,
              ),
            ),
          );
        }
        totalAmountCents = parsedTotal;
      } else {
        totalWeightGrams = ScaledDecimalFormatter.tryParse(
          form.totalWeight,
          3,
        );
        pricePerKgMicros = ScaledDecimalFormatter.tryParse(
          form.pricePerKg,
          6,
        );
        if (totalWeightGrams == null || totalWeightGrams <= 0) {
          return Result.failure(
            _fieldValidationError(
              LivestockSaleFormField.totalWeight,
              LivestockSaleStrings.saleError(
                LivestockSaleError.invalidTotalWeight,
              ),
            ),
          );
        }
        if (pricePerKgMicros == null || pricePerKgMicros <= 0) {
          return Result.failure(
            _fieldValidationError(
              LivestockSaleFormField.pricePerKilogram,
              LivestockSaleStrings.saleError(
                LivestockSaleError.invalidPricePerKg,
              ),
            ),
          );
        }
        totalAmountCents = LivestockSaleAmountCalculator.totalCents(
          totalWeightGrams: totalWeightGrams,
          pricePerKgMicros: pricePerKgMicros,
        );
      }
      int? paymentAmountCents;
      switch (form.paymentCondition) {
        case LivestockSalePaymentCondition.total:
          paymentAmountCents = totalAmountCents;
        case LivestockSalePaymentCondition.partial:
          paymentAmountCents = ScaledDecimalFormatter.tryParse(
            form.amountToCollect,
            2,
          );
          if (paymentAmountCents == null) {
            return Result.failure(
              _fieldValidationError(
                LivestockSaleFormField.amountToCollect,
                LivestockSaleStrings.saleError(
                  LivestockSaleError.invalidInitialPaymentAmount,
                ),
              ),
            );
          }
        case LivestockSalePaymentCondition.pending:
          paymentAmountCents = null;
      }
      final payment = paymentAmountCents == null
          ? null
          : LivestockSaleInitialPaymentDraft(
              date: form.paymentDate,
              amountCents: paymentAmountCents,
              method: form.paymentMethod,
              observations: form.paymentObservations,
            );
      return Result.success(
        // El borrador de dominio ya no contiene texto numerico ambiguo y queda
        // listo para ser validado y persistido por el caso de uso.
        LivestockSaleDraft(
          establishmentId: form.establishmentId,
          operationDate: form.operationDate,
          buyerType: form.buyerType,
          buyerName: form.buyerName,
          isCompany: form.isCompany,
          buyerLastName: form.isCompany ? null : form.buyerLastName,
          dteNumber: form.dteNumber,
          saleType: form.saleType,
          totalWeightGrams: totalWeightGrams,
          pricePerKgMicros: pricePerKgMicros,
          totalAmountCents: totalAmountCents,
          observations: form.observations,
          animalIds: state.selection.animals.map((animal) => animal.id).toList(growable: false),
          paymentCondition: form.paymentCondition,
          initialPayment: payment,
        ),
      );
    } on FormatException catch (_) {
      final field = state.form.saleType == LivestockSaleType.bulk
          ? LivestockSaleFormField.bulkTotalAmount
          : LivestockSaleFormField.pricePerKilogram;
      return Result.failure(
        _fieldValidationError(
          field,
          LivestockSaleStrings.saleError(
            LivestockSaleError.invalidTotalAmount,
          ),
        ),
      );
    }
  }

  DomainException? _validateRequiredFields() {
    final form = state.form;
    if (form.buyerName.trim().isEmpty) {
      return _requiredFieldError(LivestockSaleFormField.buyerName);
    }
    if (!form.isCompany && form.buyerLastName.trim().isEmpty) {
      return _requiredFieldError(LivestockSaleFormField.buyerLastName);
    }
    if (form.dteNumber.trim().isEmpty) {
      return _requiredFieldError(LivestockSaleFormField.dteNumber);
    }
    if (form.saleType == LivestockSaleType.bulk && form.bulkTotalAmount.trim().isEmpty) {
      return _requiredFieldError(LivestockSaleFormField.bulkTotalAmount);
    }
    if (form.saleType == LivestockSaleType.perKilogram) {
      if (form.totalWeight.trim().isEmpty) {
        return _requiredFieldError(LivestockSaleFormField.totalWeight);
      }
      if (form.pricePerKg.trim().isEmpty) {
        return _requiredFieldError(LivestockSaleFormField.pricePerKilogram);
      }
    }
    if (form.paymentCondition == LivestockSalePaymentCondition.partial && form.amountToCollect.trim().isEmpty) {
      return _requiredFieldError(LivestockSaleFormField.amountToCollect);
    }
    return null;
  }

  void _emitStepError(
    Emitter<LivestockSaleState> emit,
    DomainException error,
  ) {
    // Freezed compara los errores por valor. Limpiar el anterior garantiza que
    // cada nuevo intento invalido vuelva a producir feedback visible.
    if (state.stepError == error) {
      emit(state.copyWith(stepError: null));
    }
    emit(state.copyWith(stepError: error));
  }

  LivestockSaleFormDraft _normalizeChangedForm(LivestockSaleFormDraft next) {
    // Al cambiar una opcion excluyente se eliminan valores que ya no deben
    // enviarse, aunque hayan sido completados previamente por el usuario.
    var normalized = next;
    if (next.isCompany) {
      normalized = normalized.copyWith(buyerLastName: '');
    }
    if (next.saleType != state.form.saleType) {
      normalized = next.saleType == LivestockSaleType.bulk
          ? normalized.copyWith(totalWeight: '', pricePerKg: '')
          : normalized.copyWith(bulkTotalAmount: '');
    }
    if (next.paymentCondition != LivestockSalePaymentCondition.partial) {
      normalized = normalized.copyWith(amountToCollect: '');
    }
    return normalized;
  }

  bool _hasMeaningfulDraftChanges({
    required LivestockSaleFormDraft form,
    required LivestockSaleSelection selection,
  }) {
    if (selection.animals.isNotEmpty) return true;
    final initialForm = LivestockSaleFormDraft.initial(
      establishmentId: form.establishmentId,
      today: _now(),
    );
    return form != initialForm;
  }

  DomainException _localizedSelectionError(DomainException error) {
    // Dominio conserva motivos estables y presentation agrega el mensaje en
    // español que finalmente ve el productor.
    final reason = error.reason;
    if (reason is! LivestockSaleSelectionError) return error;
    return DomainException(
      message: LivestockSaleStrings.selectionError(reason),
      code: error.code,
      reason: reason,
    );
  }

  DomainException _localizedSaleError(DomainException error) {
    final reason = error.reason;
    if (reason is! LivestockSaleError) return error;
    return DomainException(
      message: LivestockSaleStrings.saleError(reason),
      code: error.code,
      reason: reason,
    );
  }

  DomainException _localizedDraftError(DomainException error) {
    final reason = error.reason;
    if (reason is! LivestockSaleDraftError) return error;
    return DomainException(
      message: LivestockSaleStrings.draftError(reason),
      code: error.code,
      reason: reason,
    );
  }

  DomainException _saleValidationError(LivestockSaleError error) {
    return DomainException(
      message: LivestockSaleStrings.saleError(error),
      code: DomainErrorCode.validation,
      reason: error,
    );
  }

  DomainException _validationError(String message) {
    return DomainException(message: message, code: DomainErrorCode.validation);
  }

  DomainException _requiredFieldError(LivestockSaleFormField field) {
    return _fieldValidationError(
      field,
      LivestockSaleStrings.missingRequiredFields,
    );
  }

  DomainException _fieldValidationError(
    LivestockSaleFormField field,
    String message,
  ) {
    return DomainException(
      message: message,
      code: DomainErrorCode.validation,
      reason: field,
    );
  }

  Future<void> _onSaveAndExitRequested(
    _SaveAndExitRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    _draftSaveTimer?.cancel();
    emit(
      state.copyWith(
        exitStatus: LivestockSaleExitStatus.working,
        draftFeedback: null,
      ),
    );
    final result = await _persistCurrentDraft();
    final error = result.when<DomainException?>(
      success: (_) => null,
      failure: (failure) => failure,
    );
    if (error == null) {
      emit(state.copyWith(exitStatus: LivestockSaleExitStatus.completed));
    } else {
      emit(
        state.copyWith(
          exitStatus: LivestockSaleExitStatus.idle,
          draftFeedback: _localizedDraftError(error),
        ),
      );
    }
  }

  Future<void> _onDiscardAndExitRequested(
    _DiscardAndExitRequested event,
    Emitter<LivestockSaleState> emit,
  ) async {
    _draftSaveTimer?.cancel();
    emit(
      state.copyWith(
        exitStatus: LivestockSaleExitStatus.working,
        draftFeedback: null,
      ),
    );
    final result = await _deleteCurrentDraft();
    final error = result.when<DomainException?>(
      success: (_) => null,
      failure: (failure) => failure,
    );
    if (error == null) {
      emit(
        state.copyWith(
          exitStatus: LivestockSaleExitStatus.completed,
          hasDraftChanges: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          exitStatus: LivestockSaleExitStatus.idle,
          draftFeedback: _localizedDraftError(error),
        ),
      );
    }
  }

  void _scheduleDraftSave() {
    if (state.draftRecoveryStatus != LivestockSaleDraftRecoveryStatus.ready) {
      return;
    }
    _draftSaveTimer?.cancel();
    // Las pruebas pueden desactivar la espera sin cambiar la estrategia de
    // produccion, donde el debounce evita escribir por cada tecla ingresada.
    if (_draftSaveDebounce == Duration.zero) {
      unawaited(_persistCurrentDraft());
      return;
    }
    _draftSaveTimer = Timer(
      _draftSaveDebounce,
      () => unawaited(_persistCurrentDraft()),
    );
  }

  Future<Result<void>> _persistCurrentDraft() {
    return _persistSnapshot(_snapshotFromState(state));
  }

  Future<Result<void>> _persistSnapshot(
    LivestockSaleSavedDraft snapshot,
  ) {
    // Serializar escrituras evita que una respuesta lenta y antigua reemplace
    // un borrador más reciente en el almacenamiento cifrado.
    final previousWrite = _pendingDraftWrite;
    final operation = previousWrite == null
        ? _saveDraft(userId: _userId, draft: snapshot)
        : previousWrite.then(
            (_) => _saveDraft(userId: _userId, draft: snapshot),
          );
    _pendingDraftWrite = operation.then<void>((_) {});
    return operation;
  }

  Future<Result<void>> _deleteCurrentDraft() async {
    final pendingWrite = _pendingDraftWrite;
    if (pendingWrite != null) await pendingWrite;
    return _deleteDraft(
      userId: _userId,
      establishmentId: state.form.establishmentId,
    );
  }

  LivestockSaleSavedDraft _snapshotFromState(LivestockSaleState source) {
    final form = source.form;
    return LivestockSaleSavedDraft(
      establishmentId: form.establishmentId,
      operationDate: form.operationDate,
      buyerType: form.buyerType,
      buyerName: form.buyerName,
      isCompany: form.isCompany,
      buyerLastName: form.buyerLastName,
      dteNumber: form.dteNumber,
      saleType: form.saleType,
      bulkTotalAmount: form.bulkTotalAmount,
      totalWeight: form.totalWeight,
      pricePerKg: form.pricePerKg,
      paymentCondition: form.paymentCondition,
      paymentMethod: form.paymentMethod,
      amountToCollect: form.amountToCollect,
      paymentDate: form.paymentDate,
      observations: form.observations,
      paymentObservations: form.paymentObservations,
      selectedRfidTagNumbers: source.selection.animals.map((animal) => animal.rfidTagNumber).toList(growable: false),
      currentStep: LivestockSaleDraftStep.values[source.currentStep.index],
      updatedAt: _now(),
    );
  }

  LivestockSaleFormDraft _formFromSavedDraft(
    LivestockSaleSavedDraft savedDraft,
  ) {
    return LivestockSaleFormDraft(
      establishmentId: savedDraft.establishmentId,
      operationDate: savedDraft.operationDate,
      buyerType: savedDraft.buyerType,
      buyerName: savedDraft.buyerName,
      isCompany: savedDraft.isCompany,
      buyerLastName: savedDraft.buyerLastName,
      dteNumber: savedDraft.dteNumber,
      saleType: savedDraft.saleType,
      bulkTotalAmount: savedDraft.bulkTotalAmount,
      totalWeight: savedDraft.totalWeight,
      pricePerKg: savedDraft.pricePerKg,
      paymentCondition: savedDraft.paymentCondition,
      paymentMethod: savedDraft.paymentMethod,
      amountToCollect: savedDraft.amountToCollect,
      paymentDate: savedDraft.paymentDate,
      observations: savedDraft.observations,
      paymentObservations: savedDraft.paymentObservations,
    );
  }

  @override
  Future<void> close() {
    _draftSaveTimer?.cancel();
    if (!_persistDraftOnClose) return super.close();
    final shouldPersist =
        state.hasDraftChanges &&
        state.submitResult is! Data<LivestockSale> &&
        state.exitStatus != LivestockSaleExitStatus.completed;
    if (!shouldPersist && _pendingDraftWrite == null) {
      return super.close();
    }
    return _closeAfterPendingWrites(shouldPersist: shouldPersist);
  }

  Future<void> _closeAfterPendingWrites({required bool shouldPersist}) async {
    if (shouldPersist) {
      await _persistCurrentDraft();
    } else {
      final pendingWrite = _pendingDraftWrite;
      if (pendingWrite != null) await pendingWrite;
    }
    return super.close();
  }
}
