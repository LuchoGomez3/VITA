/// Tokens de espaciado oficiales de la app mobile.
///
/// Este archivo centraliza valores de espaciado para que las pantallas reutilicen
/// medidas consistentes y no definan `EdgeInsets` sueltos.
class AppSpacing {
  const AppSpacing._();

  // Espaciado muy pequeno para elementos muy cercanos.
  static const xxxs = 1.0;

  /// Espaciado extra pequeno para elementos muy cercanos.
  static const xxs = 4.0;

  /// Espaciado pequeno para elementos cercanos.
  static const xs = 8.0;

  /// Espaciado medio para elementos moderadamente espaciados.
  static const sm = 12.0;

  /// Espaciado base para separaciones estandar y paddings frecuentes.
  static const md = 16.0;

  /// Espaciado grande para elementos espaciados.
  static const lg = 24.0;

  /// Espaciado extra grande para elementos que van al fondo de la pantalla.
  static const xl = 32.0;
}
