import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_draft_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';

void main() {
  test('guarda, recupera y elimina un borrador aislado', () async {
    final storage = _MemoryStorage();
    final repository = LivestockSaleDraftRepositoryImpl(
      secureStorage: storage,
    );
    final draft = _draft();

    await repository.save(userId: 'user-id', draft: draft);
    final loaded = await repository.load(
      userId: 'user-id',
      establishmentId: 'establishment-id',
    );

    expect(loaded.when(success: (value) => value, failure: (_) => null), draft);

    await repository.delete(
      userId: 'user-id',
      establishmentId: 'establishment-id',
    );
    final deleted = await repository.load(
      userId: 'user-id',
      establishmentId: 'establishment-id',
    );
    expect(
      deleted.when(success: (value) => value, failure: (_) => draft),
      isNull,
    );
  });
}

LivestockSaleSavedDraft _draft() {
  final date = DateTime(2026, 10, 20);
  return LivestockSaleSavedDraft(
    establishmentId: 'establishment-id',
    operationDate: date,
    buyerType: LivestockSaleBuyerType.privateBuyer,
    buyerName: 'Juan',
    isCompany: false,
    buyerLastName: 'Perez',
    dteNumber: '001234567-9',
    saleType: LivestockSaleType.bulk,
    bulkTotalAmount: '10000',
    totalWeight: '',
    pricePerKg: '',
    paymentCondition: LivestockSalePaymentCondition.total,
    paymentMethod: LivestockSalePaymentMethod.cash,
    amountToCollect: '',
    paymentDate: date,
    observations: '',
    paymentObservations: '',
    selectedRfidTagNumbers: const ['982000000001295'],
    currentStep: LivestockSaleDraftStep.animals,
    updatedAt: date,
  );
}

class _MemoryStorage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
