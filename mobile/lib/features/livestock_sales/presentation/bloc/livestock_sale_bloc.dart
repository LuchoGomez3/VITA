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
    required RemoveAnimalFromLivestockSaleSelectionUseCase removeAnimal,
    required ConfirmLivestockSaleUseCase confirmSale,
    DateTime Function()? now,
  }) : _addAnimal = addAnimal,
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
    on<_AnimalRemoveRequested>(_onAnimalRemoveRequested);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final AddAnimalToLivestockSaleSelectionUseCase _addAnimal;
  final RemoveAnimalFromLivestockSaleSelectionUseCase _removeAnimal;
  final ConfirmLivestockSaleUseCase _confirmSale;
  final DateTime Function() _now;

  void _onFormChanged(
    _FormChanged event,
    Emitter<LivestockSaleState> emit,
  ) {
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
      case Success<LivestockSaleSelection>(:final data):
        emit(
          state.copyWith(
            selection: data,
            animalSelectionResult: ResultState.data(data),
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

    final error = switch (state.currentStep) {
      LivestockSaleStep.animals =>
        state.selection.animals.isEmpty ? _validationError(LivestockSaleStrings.requiredAnimals) : null,
      LivestockSaleStep.operation => _validateCompleteDraft(),
      LivestockSaleStep.review => null,
    };
    if (error != null) {
      emit(state.copyWith(stepError: error));
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
    if (state.currentStep != LivestockSaleStep.review || state.submitResult is Loading<LivestockSale>) {
      return;
    }

    final draftResult = _buildDomainDraft();
    if (draftResult case Failure<LivestockSaleDraft>(:final error)) {
      emit(state.copyWith(stepError: error));
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
      if (form.saleType == LivestockSaleType.bulk) {
        totalAmountCents = ScaledDecimalFormatter.parse(form.bulkTotalAmount, 2);
      } else {
        totalWeightGrams = ScaledDecimalFormatter.parse(form.totalWeight, 3);
        pricePerKgMicros = ScaledDecimalFormatter.parse(form.pricePerKg, 6);
        if (totalWeightGrams <= 0 || pricePerKgMicros <= 0) {
          return Result.failure(
            _validationError(LivestockSaleStrings.invalidNumber),
          );
        }
        totalAmountCents = LivestockSaleAmountCalculator.totalCents(
          totalWeightGrams: totalWeightGrams,
          pricePerKgMicros: pricePerKgMicros,
        );
      }
      final paymentAmountCents = switch (form.paymentCondition) {
        LivestockSalePaymentCondition.total => totalAmountCents,
        LivestockSalePaymentCondition.partial => ScaledDecimalFormatter.parse(form.amountToCollect, 2),
        LivestockSalePaymentCondition.pending => null,
      };
      final payment = paymentAmountCents == null
          ? null
          : LivestockSaleInitialPaymentDraft(
              date: form.paymentDate,
              amountCents: paymentAmountCents,
              method: form.paymentMethod,
              observations: form.paymentObservations,
            );
      return Result.success(
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
      return Result.failure(_validationError(LivestockSaleStrings.invalidNumber));
    }
  }

  LivestockSaleFormDraft _normalizeChangedForm(LivestockSaleFormDraft next) {
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
}
