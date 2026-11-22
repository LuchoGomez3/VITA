import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_catalog.freezed.dart';

/// Formularios que la aplicación sabe registrar.
enum HealthPracticeKind {
  /// Vacuna, antiparasitario o tratamiento.
  application('aplicacion'),

  /// Toma de una muestra.
  sampling('muestreo'),

  /// Observación de una lesión.
  lesion('lesion');

  const HealthPracticeKind(this.code);

  /// Código del contrato de Sanidad.
  final String code;
}

/// Práctica habilitada por el catálogo.
@freezed
sealed class HealthPractice with _$HealthPractice {
  /// Define la práctica y su variante de formulario.
  const factory HealthPractice({
    required String id,
    required String name,
    required HealthPracticeKind kind,
    @Default([]) List<String> productIds,
  }) = _HealthPractice;
}

/// Producto disponible para una aplicación.
@freezed
sealed class HealthProduct with _$HealthProduct {
  /// Define el producto que se puede seleccionar.
  const factory HealthProduct({required String id, required String name}) = _HealthProduct;
}

/// Catálogo de Sanidad descargado para un establecimiento.
@freezed
sealed class HealthCatalog with _$HealthCatalog {
  /// Construye una instantánea del catálogo.
  const factory HealthCatalog({
    required String establishmentId,
    required List<HealthPractice> practices,
    required List<HealthProduct> products,
  }) = _HealthCatalog;
}
