import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';

/// Valida el formulario y confirma una venta primero en SQLite.
class ConfirmLivestockSaleUseCase {
  /// Crea el caso de uso con reloj e identidades inyectables para pruebas.
  ConfirmLivestockSaleUseCase({
    required LivestockSaleRepository repository,
    DateTime Function()? now,
    String Function()? createId,
  }) : _repository = repository,
       _now = now ?? DateTime.now,
       _createId = createId ?? generateUuidV4;

  final LivestockSaleRepository _repository;
  final DateTime Function() _now;
  final String Function() _createId;

  /// Confirma [draft] sin esperar conectividad.
  Future<Result<LivestockSale>> call(LivestockSaleDraft draft) {
    // Normalizar antes de validar evita persistir diferencias irrelevantes de
    // espacios y asegura que la validacion opere sobre el dato definitivo.
    final current = _now();
    final normalized = _normalize(draft);
    final validationError = validate(draft: normalized, today: current);
    if (validationError != null) {
      return Future.value(_failure(validationError));
    }

    final timestamp = current.toUtc();
    final paymentDraft = normalized.initialPayment;

    // Venta y cobro reciben UUID en el dispositivo. Esto permite guardar sin
    // conexion y reintentar el mismo POST sin crear duplicados en backend.
    final sale = LivestockSale(
      id: _createId(),
      establishmentId: normalized.establishmentId,
      operationDate: normalized.operationDate,
      buyerType: normalized.buyerType,
      buyerName: normalized.buyerName,
      isCompany: normalized.isCompany,
      buyerLastName: normalized.buyerLastName,
      dteNumber: normalized.dteNumber,
      saleType: normalized.saleType,
      totalWeightGrams: normalized.totalWeightGrams,
      pricePerKgMicros: normalized.pricePerKgMicros,
      totalAmountCents: normalized.totalAmountCents,
      observations: normalized.observations,
      animalIds: normalized.animalIds,
      paymentCondition: normalized.paymentCondition,
      initialPayment: paymentDraft == null
          ? null
          : LivestockSaleInitialPayment(
              id: _createId(),
              date: paymentDraft.date,
              amountCents: paymentDraft.amountCents,
              method: paymentDraft.method,
              observations: paymentDraft.observations,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
      createdAt: timestamp,
      updatedAt: timestamp,
      syncStatus: LivestockSaleSyncStatus.pending,
    );
    return _repository.createSale(sale);
  }

  /// Devuelve el primer error siguiendo el orden del formulario.
  LivestockSaleError? validate({
    required LivestockSaleDraft draft,
    required DateTime today,
  }) {
    // El orden sigue la disposicion del formulario para que el primer mensaje
    // lleve al usuario al bloque que debe corregir primero.
    if (draft.establishmentId.trim().isEmpty) {
      return LivestockSaleError.requiredEstablishment;
    }
    if (_dateOnly(draft.operationDate).isAfter(_dateOnly(today))) {
      return LivestockSaleError.futureOperationDate;
    }
    if (draft.buyerName.isEmpty) return LivestockSaleError.requiredBuyerName;
    if (draft.isCompany) {
      if (draft.buyerLastName != null) {
        return LivestockSaleError.companyWithLastName;
      }
    } else {
      if (!_isPersonName(draft.buyerName)) {
        return LivestockSaleError.invalidBuyerName;
      }
      final lastName = draft.buyerLastName;
      if (lastName == null || lastName.isEmpty) {
        return LivestockSaleError.requiredBuyerLastName;
      }
      if (!_isPersonName(lastName)) {
        return LivestockSaleError.invalidBuyerLastName;
      }
    }
    // No se calcula el verificador: algunas series convierten resultados de
    // dos dígitos mediante una tabla oficial que la aplicación no conoce.
    if (!RegExp(r'^\d+-[0-9A-Z]$').hasMatch(draft.dteNumber)) {
      return LivestockSaleError.invalidDteNumber;
    }
    if (draft.animalIds.isEmpty ||
        draft.animalIds.any((id) => id.isEmpty) ||
        draft.animalIds.toSet().length != draft.animalIds.length) {
      return LivestockSaleError.invalidAnimals;
    }
    if (draft.totalAmountCents <= 0 || draft.totalAmountCents > LivestockSaleAmountCalculator.maximumTotalCents) {
      return LivestockSaleError.invalidTotalAmount;
    }

    final saleTypeError = _validateSaleType(draft);
    if (saleTypeError != null) return saleTypeError;

    final payment = draft.initialPayment;
    // Cada condicion impone una forma distinta del cobro inicial: inexistente,
    // igual al total o estrictamente menor al monto de la venta.
    switch (draft.paymentCondition) {
      case LivestockSalePaymentCondition.pending:
        if (payment != null) return LivestockSaleError.pendingWithInitialPayment;
      case LivestockSalePaymentCondition.total:
        if (payment == null) return LivestockSaleError.requiredInitialPayment;
        if (payment.amountCents != draft.totalAmountCents) {
          return LivestockSaleError.invalidInitialPaymentAmount;
        }
      case LivestockSalePaymentCondition.partial:
        if (payment == null) return LivestockSaleError.requiredInitialPayment;
        if (payment.amountCents <= 0) {
          return LivestockSaleError.nonPositiveInitialPaymentAmount;
        }
        if (payment.amountCents >= draft.totalAmountCents) {
          return LivestockSaleError.initialPaymentNotLessThanTotal;
        }
    }
    if (payment != null && _dateOnly(payment.date).isAfter(_dateOnly(today))) {
      return LivestockSaleError.futureInitialPaymentDate;
    }
    return null;
  }

  LivestockSaleError? _validateSaleType(LivestockSaleDraft draft) {
    // Las dos modalidades son excluyentes para impedir que datos residuales
    // cambien la interpretacion comercial de la operacion.
    if (draft.saleType == LivestockSaleType.bulk) {
      return draft.totalWeightGrams == null && draft.pricePerKgMicros == null
          ? null
          : LivestockSaleError.bulkWithUnitValues;
    }

    final weight = draft.totalWeightGrams;
    if (weight == null || weight <= 0 || weight > 9999999999) {
      return LivestockSaleError.invalidTotalWeight;
    }
    final price = draft.pricePerKgMicros;
    if (price == null || price <= 0 || price > int.parse('999999999999999999')) {
      return LivestockSaleError.invalidPricePerKg;
    }
    try {
      // Recalcular en dominio impide confiar en un total manipulado desde UI y
      // aplica la misma regla de truncado que se usa en la previsualizacion.
      final calculated = LivestockSaleAmountCalculator.totalCents(
        totalWeightGrams: weight,
        pricePerKgMicros: price,
      );
      return calculated == draft.totalAmountCents ? null : LivestockSaleError.inconsistentCalculatedTotal;
    } on FormatException {
      return LivestockSaleError.invalidTotalAmount;
    }
  }

  LivestockSaleDraft _normalize(LivestockSaleDraft draft) {
    return draft.copyWith(
      establishmentId: draft.establishmentId.trim(),
      buyerName: _normalizeText(draft.buyerName) ?? '',
      buyerLastName: _normalizeText(draft.buyerLastName),
      dteNumber: draft.dteNumber.trim().toUpperCase(),
      observations: _normalizeText(draft.observations),
      animalIds: draft.animalIds.map((id) => id.trim()).toList(growable: false),
      initialPayment: draft.initialPayment?.copyWith(
        observations: _normalizeText(draft.initialPayment?.observations),
      ),
    );
  }

  static String? _normalizeText(String? value) {
    if (value == null) return null;
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized.isEmpty ? null : normalized;
  }

  static bool _isPersonName(String value) {
    return RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]+$').hasMatch(value);
  }

  static DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  Result<LivestockSale> _failure(LivestockSaleError error) {
    return Result.failure(
      DomainException(
        message: error.name,
        code: DomainErrorCode.validation,
        reason: error,
      ),
    );
  }
}
