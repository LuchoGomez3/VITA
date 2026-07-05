/// Tokens de redondeo oficiales de la app mobile.
///
/// Este archivo centraliza valores de redondeo para que las pantallas reutilicen
/// medidas consistentes y no definan `BorderRadius` sueltos.
class AppRadius {
  const AppRadius._();

  /// Redondeo pequeno para botones y cards.
  static const sm = 8.0;

  /// Redondeo medio para inputs y cards.
  static const md = 12.0;

  /// Redondeo grande para cards y componentes elevados.
  static const lg = 20.0;
}
