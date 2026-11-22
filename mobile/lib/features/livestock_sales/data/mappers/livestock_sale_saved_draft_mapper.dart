import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';

/// Traduce el borrador de dominio al formato versionado del storage cifrado.
abstract final class LivestockSaleSavedDraftMapper {
  /// Serializa valores exactos y nombres estables de los enums.
  static Map<String, Object?> toJson(LivestockSaleSavedDraft draft) => {
    'establishment_id': draft.establishmentId,
    'operation_date': draft.operationDate.toIso8601String(),
    'buyer_type': draft.buyerType.name,
    'buyer_name': draft.buyerName,
    'is_company': draft.isCompany,
    'buyer_last_name': draft.buyerLastName,
    'dte_number': draft.dteNumber,
    'sale_type': draft.saleType.name,
    'bulk_total_amount': draft.bulkTotalAmount,
    'total_weight': draft.totalWeight,
    'price_per_kg': draft.pricePerKg,
    'payment_condition': draft.paymentCondition.name,
    'payment_method': draft.paymentMethod.name,
    'amount_to_collect': draft.amountToCollect,
    'payment_date': draft.paymentDate.toIso8601String(),
    'observations': draft.observations,
    'payment_observations': draft.paymentObservations,
    'selected_rfid_tag_numbers': draft.selectedRfidTagNumbers,
    'current_step': draft.currentStep.name,
    'updated_at': draft.updatedAt.toIso8601String(),
  };

  /// Reconstruye el dominio y falla si el contenido fue truncado o alterado.
  static LivestockSaleSavedDraft fromJson(Map<String, Object?> json) {
    return LivestockSaleSavedDraft(
      establishmentId: json['establishment_id']! as String,
      operationDate: DateTime.parse(json['operation_date']! as String),
      buyerType: _enumByName(
        LivestockSaleBuyerType.values,
        json['buyer_type']! as String,
      ),
      buyerName: json['buyer_name']! as String,
      isCompany: json['is_company']! as bool,
      buyerLastName: json['buyer_last_name']! as String,
      dteNumber: json['dte_number']! as String,
      saleType: _enumByName(
        LivestockSaleType.values,
        json['sale_type']! as String,
      ),
      bulkTotalAmount: json['bulk_total_amount']! as String,
      totalWeight: json['total_weight']! as String,
      pricePerKg: json['price_per_kg']! as String,
      paymentCondition: _enumByName(
        LivestockSalePaymentCondition.values,
        json['payment_condition']! as String,
      ),
      paymentMethod: _enumByName(
        LivestockSalePaymentMethod.values,
        json['payment_method']! as String,
      ),
      amountToCollect: json['amount_to_collect']! as String,
      paymentDate: DateTime.parse(json['payment_date']! as String),
      observations: json['observations']! as String,
      paymentObservations: json['payment_observations']! as String,
      selectedRfidTagNumbers: (json['selected_rfid_tag_numbers']! as List<Object?>).cast<String>(),
      currentStep: _enumByName(
        LivestockSaleDraftStep.values,
        json['current_step']! as String,
      ),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }

  static T _enumByName<T extends Enum>(List<T> values, String name) {
    return values.firstWhere((value) => value.name == name);
  }
}
