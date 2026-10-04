import 'dart:convert';

import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Traduce la venta de dominio al agregado tecnico persistido por Brick.
abstract final class LivestockSaleBrickMapper {
  /// Serializa la operacion sin introducir aritmetica de punto flotante.
  static BrickLivestockSaleModel toBrick(LivestockSale sale) {
    return BrickLivestockSaleModel(
      localId: sale.id,
      establishmentId: sale.establishmentId,
      operationDate: sale.operationDate,
      buyerType: sale.buyerType.value,
      buyerName: sale.buyerName,
      isCompany: sale.isCompany,
      buyerLastName: sale.buyerLastName,
      dteNumber: sale.dteNumber,
      saleType: sale.saleType.value,
      totalWeightKg: sale.totalWeightGrams == null ? null : ScaledDecimalFormatter.format(sale.totalWeightGrams!, 3),
      pricePerKg: sale.pricePerKgMicros == null ? null : ScaledDecimalFormatter.format(sale.pricePerKgMicros!, 6),
      totalAmount: DecimalAmountFormatter.centsToDecimal(sale.totalAmountCents),
      observations: sale.observations,
      animalIdsJson: jsonEncode(sale.animalIds),
      paymentCondition: sale.paymentCondition.value,
      initialPaymentJson: _paymentToJson(sale.initialPayment),
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
      syncStatus: _syncStatusToBrick(sale.syncStatus),
      syncErrorCode: sale.syncErrorCode,
    );
  }

  /// Rehidrata una venta guardada localmente.
  static LivestockSale fromBrick(BrickLivestockSaleModel model) {
    final animalIds = jsonDecode(model.animalIdsJson);
    if (animalIds is! List || animalIds.any((id) => id is! String)) {
      throw const FormatException('Invalid stored animal IDs.');
    }
    return LivestockSale(
      id: model.localId,
      establishmentId: model.establishmentId,
      operationDate: model.operationDate,
      buyerType: _enumByValue(LivestockSaleBuyerType.values, model.buyerType, (value) => value.value),
      buyerName: model.buyerName,
      isCompany: model.isCompany,
      buyerLastName: model.buyerLastName,
      dteNumber: model.dteNumber,
      saleType: _enumByValue(LivestockSaleType.values, model.saleType, (value) => value.value),
      totalWeightGrams: model.totalWeightKg == null ? null : ScaledDecimalFormatter.parse(model.totalWeightKg!, 3),
      pricePerKgMicros: model.pricePerKg == null ? null : ScaledDecimalFormatter.parse(model.pricePerKg!, 6),
      totalAmountCents: DecimalAmountFormatter.decimalToCents(model.totalAmount),
      observations: model.observations,
      animalIds: animalIds.cast<String>(),
      paymentCondition: _enumByValue(
        LivestockSalePaymentCondition.values,
        model.paymentCondition,
        (value) => value.value,
      ),
      initialPayment: _paymentFromJson(model.initialPaymentJson),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncStatus: _syncStatusFromBrick(model.syncStatus),
      syncErrorCode: model.syncErrorCode,
    );
  }

  static String? _paymentToJson(LivestockSaleInitialPayment? payment) {
    if (payment == null) return null;
    return jsonEncode({
      'id': payment.id,
      'fecha_cobro': _dateToBackend(payment.date),
      'monto': DecimalAmountFormatter.centsToDecimal(payment.amountCents),
      'medio_cobro': payment.method.value,
      'observaciones': payment.observations,
      'created_at': payment.createdAt.toIso8601String(),
      'updated_at': payment.updatedAt.toIso8601String(),
      'deleted_at': null,
    });
  }

  static LivestockSaleInitialPayment? _paymentFromJson(String? encoded) {
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid stored initial payment.');
    }
    return LivestockSaleInitialPayment(
      id: decoded['id'] as String,
      date: DateTime.parse(decoded['fecha_cobro'] as String),
      amountCents: DecimalAmountFormatter.decimalToCents(decoded['monto'] as String),
      method: _enumByValue(
        LivestockSalePaymentMethod.values,
        decoded['medio_cobro'] as String,
        (value) => value.value,
      ),
      observations: decoded['observaciones'] as String?,
      createdAt: DateTime.parse(decoded['created_at'] as String),
      updatedAt: DateTime.parse(decoded['updated_at'] as String),
    );
  }

  static T _enumByValue<T>(
    Iterable<T> values,
    String stored,
    String Function(T value) valueOf,
  ) {
    for (final value in values) {
      if (valueOf(value) == stored) return value;
    }
    throw FormatException('Unsupported stored value: $stored');
  }

  static BrickLivestockSaleSyncStatus _syncStatusToBrick(LivestockSaleSyncStatus status) {
    return switch (status) {
      LivestockSaleSyncStatus.pending => BrickLivestockSaleSyncStatus.pending,
      LivestockSaleSyncStatus.synchronized => BrickLivestockSaleSyncStatus.synchronized,
      LivestockSaleSyncStatus.rejected => BrickLivestockSaleSyncStatus.rejected,
    };
  }

  static LivestockSaleSyncStatus _syncStatusFromBrick(BrickLivestockSaleSyncStatus status) {
    return switch (status) {
      BrickLivestockSaleSyncStatus.pending => LivestockSaleSyncStatus.pending,
      BrickLivestockSaleSyncStatus.synchronized => LivestockSaleSyncStatus.synchronized,
      BrickLivestockSaleSyncStatus.rejected => LivestockSaleSyncStatus.rejected,
    };
  }

  static String _dateToBackend(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
