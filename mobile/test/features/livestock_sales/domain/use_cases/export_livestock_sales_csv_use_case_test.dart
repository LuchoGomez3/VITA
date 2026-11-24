import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/export_livestock_sales_csv_use_case.dart';

void main() {
  const export = ExportLivestockSalesCsvUseCase();

  test('exporta el saldo y el cobro local en pesos y escapa texto libre', () {
    final csv = export([_sale]);
    const header =
        'fecha_operacion,comprador,nro_dte,tipo_venta,cantidad_animales,'
        'monto_total,monto_cobrado,saldo_pendiente,condicion_cobro,estado_sincronizacion,observaciones';
    final row = [
      '2026-11-24,"Frigorífico Norte, S.A.","001234567-9",al_bulto,2',
      '4000000.00,1250000.05,2749999.95,parcial,pendiente,"Pago ""inicial""\nEntrega en campo"',
    ].join(',');

    expect(csv, '$header\r\n$row\r\n');
  });

  test('prioriza los importes sincronizados y exporta texto con prefijo de fórmula', () {
    final csv = export([
      _sale.copyWith(
        collectedAmountCents: 200000000,
        pendingAmountCents: 200000000,
        syncStatus: LivestockSaleSyncStatus.synchronized,
        observations: '=1+1',
      ),
    ]);

    expect(csv, contains('4000000.00,2000000.00,2000000.00,parcial,sincronizada,"\'=1+1"'));
  });
}

final _sale = LivestockSale(
  id: 'venta',
  establishmentId: 'establecimiento',
  operationDate: DateTime(2026, 11, 24),
  buyerType: LivestockSaleBuyerType.slaughterhouse,
  buyerName: 'Frigorífico Norte, S.A.',
  isCompany: true,
  dteNumber: '001234567-9',
  saleType: LivestockSaleType.bulk,
  totalAmountCents: 400000000,
  animalIds: const ['animal-a', 'animal-b'],
  paymentCondition: LivestockSalePaymentCondition.partial,
  createdAt: DateTime.utc(2026, 11, 24),
  updatedAt: DateTime.utc(2026, 11, 24),
  syncStatus: LivestockSaleSyncStatus.pending,
  observations: 'Pago "inicial"\nEntrega en campo',
  initialPayment: LivestockSaleInitialPayment(
    id: 'cobro',
    date: DateTime(2026, 11, 24),
    amountCents: 125000005,
    method: LivestockSalePaymentMethod.bankTransfer,
    createdAt: DateTime.utc(2026, 11, 24),
    updatedAt: DateTime.utc(2026, 11, 24),
  ),
);
