/// Nombres compartidos por las secciones de movimientos financieros.
abstract final class FinancialMovementStrings {
  /// Título del historial financiero del establecimiento.
  static const title = 'Movimientos';

  /// Sección de gastos operativos.
  static const expenses = 'Egresos';

  /// Sección de operaciones comerciales de hacienda.
  static const sales = 'Ventas';

  /// Acción compartida para abrir el registro de una operación comercial.
  static const registerSale = 'Registrar venta';

  /// Descripción de un único movimiento visible.
  static const oneRecord = 'registro encontrado';

  /// Descripción de varios movimientos visibles.
  static const records = 'registros encontrados';

  /// Presenta la cantidad respetando el singular y el plural del historial.
  static String recordCount(int count) => '$count ${count == 1 ? oneRecord : records}';
}
