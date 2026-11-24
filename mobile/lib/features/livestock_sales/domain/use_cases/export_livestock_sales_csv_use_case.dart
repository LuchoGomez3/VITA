import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Genera un CSV con las ventas visibles en el historial local.
class ExportLivestockSalesCsvUseCase {
  /// Crea la exportación independiente de la conexión.
  const ExportLivestockSalesCsvUseCase();

  static final _formulaPrefix = RegExp(r'^\s*[=+@-]');

  /// Serializa una fila por venta y conserva los importes en pesos.
  String call(List<LivestockSale> sales) {
    const header =
        'fecha_operacion,comprador,nro_dte,tipo_venta,cantidad_animales,'
        'monto_total,monto_cobrado,saldo_pendiente,condicion_cobro,estado_sincronizacion,observaciones';
    return [header, ...sales.map(_row), ''].join('\r\n');
  }

  String _row(LivestockSale sale) {
    final collected = sale.collectedAmountCents ?? sale.initialPayment?.amountCents ?? 0;
    final pending = sale.pendingAmountCents ?? sale.totalAmountCents - collected;
    final buyer = '${sale.buyerName} ${sale.buyerLastName ?? ''}'.trim();
    return [
      sale.operationDate.toIso8601String().split('T').first,
      _textCell(buyer),
      _textCell(sale.dteNumber),
      sale.saleType.value,
      sale.animalIds.length.toString(),
      DecimalAmountFormatter.centsToDecimal(sale.totalAmountCents),
      DecimalAmountFormatter.centsToDecimal(collected),
      DecimalAmountFormatter.centsToDecimal(pending),
      sale.paymentCondition.value,
      switch (sale.syncStatus) {
        LivestockSaleSyncStatus.pending => 'pendiente',
        LivestockSaleSyncStatus.synchronized => 'sincronizada',
        LivestockSaleSyncStatus.rejected => 'rechazada',
      },
      _textCell(sale.observations ?? ''),
    ].join(',');
  }

  String _textCell(String value) {
    final text = _formulaPrefix.hasMatch(value) ? "'$value" : value;
    return '"${text.replaceAll('"', '""')}"';
  }
}
