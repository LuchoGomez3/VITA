import 'package:meta/meta.dart';

/// Superficie productiva exacta expresada en décimas de hectárea.
@immutable
final class LotSurface {
  const LotSurface._(this.tenths);

  /// Crea una superficie positiva desde décimas exactas.
  factory LotSurface.fromTenths(int tenths) {
    if (tenths <= 0) {
      throw ArgumentError.value(tenths, 'tenths', 'Must be positive.');
    }
    return LotSurface._(tenths);
  }

  /// Convierte hectáreas a una única cifra decimal.
  factory LotSurface.fromHectares(num hectares) => LotSurface.fromTenths(
    (hectares.toDouble() * 10).round(),
  );

  /// Intenta interpretar texto con coma o punto decimal.
  static LotSurface? tryParse(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0) return null;
    return LotSurface.fromHectares(value);
  }

  /// Valor canónico persistido en SQLite.
  final int tenths;

  /// Valor usado por presentación y contrato REST.
  double get hectares => tenths / 10;

  @override
  bool operator ==(Object other) => other is LotSurface && other.tenths == tenths;

  @override
  int get hashCode => tenths.hashCode;

  @override
  String toString() => hectares.toStringAsFixed(1);
}
