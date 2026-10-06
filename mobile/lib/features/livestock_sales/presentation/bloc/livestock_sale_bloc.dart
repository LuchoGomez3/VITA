import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/search_livestock_sale_animals_by_rfid_prefix_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

part 'livestock_sale_bloc.freezed.dart';
part 'livestock_sale_event.dart';
part 'livestock_sale_state.dart';

/// Coordina el borrador y la navegacion del registro offline de una venta.
class LivestockSaleBloc extends Bloc<LivestockSaleEvent, LivestockSaleState> {
  /// Crea el BLoC con los casos de uso resueltos fuera de presentation.
  LivestockSaleBloc({
    required String establishmentId,
    required AddAnimalToLivestockSaleSelectionUseCase addAnimal,
    required SearchLivestockSaleAnimalsByRfidPrefixUseCase searchAnimalsByRfidPrefix,
    required RemoveAnimalFromLivestockSaleSelectionUseCase removeAnimal,
    required ConfirmLivestockSaleUseCase confirmSale,
    DateTime Function()? now,
  }) : _addAnimal = addAnimal,
       _searchAnimalsByRfidPrefix = searchAnimalsByRfidPrefix,
       _removeAnimal = removeAnimal,
       _confirmSale = confirmSale,
       _now = now ?? DateTime.now,
       super(
         LivestockSaleState(
           form: LivestockSaleFormDraft.initial(
             establishmentId: establishmentId,
             today: (now ?? DateTime.now)(),
           ),
         ),
       ) {
    on<_FormChanged>(_onFormChanged);
    on<_AnimalAddRequested>(_onAnimalAddRequested);
    on<_RfidPrefixChanged>(_onRfidPrefixChanged);
    on<_AnimalRemoveRequested>(_onAnimalRemoveRequested);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final AddAnimalToLivestockSaleSelectionUseCase _addAnimal;
  final SearchLivestockSaleAnimalsByRfidPrefixUseCase _searchAnimalsByRfidPrefix;
  final RemoveAnimalFromLivestockSaleSelectionUseCase _removeAnimal;
  final ConfirmLivestockSaleUseCase _confirmSale;
  final DateTime Function() _now;

  void _onFormChanged(
    _FormChanged event,
    Emitter<LivestockSaleState> emit,
  ) {
    // Centralizar la normalizacion aca mantiene iguales los datos aunque el
    // cambio venga de otro widget o de una futura restauracion del borrador.
    emit(
      state.copyWith(
        form: _normalizeChangedForm(event.form),
        stepError: null,
      ),
    );
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
          ),
        );
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

  void _onAnimalRemoveRequested(
    _AnimalRemoveRequested event,
    Emitter<LivestockSaleState> emit,
  ) {
    final selection = _removeAnimal(
      animalId: event.animalId,
      selection: state.selection,
    );
    emit(
      state.copyWith(
        selection: selection,
        animalSelectionResult: ResultState.data(selection),
        stepError: null,
      ),
    );
  }

  void _onNextStepRequested(
    _NextStepRequested event,
    Emitter<LivestockSaleState> emit,
  ) {
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
  }

  void _onPreviousStepRequested(
    _PreviousStepRequested event,
    Emitter<LivestockSaleState> emit,
  ) {
    if (state.currentStep == LivestockSaleStep.animals) return;
    emit(
      state.copyWith(
        currentStep: LivestockSaleStep.values[state.currentStep.index - 1],
        stepError: null,
      ),
    );
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
}
