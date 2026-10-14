import 'package:freezed_annotation/freezed_annotation.dart';

part 'forage_resource.freezed.dart';

/// Opción de recurso forrajero identificada por un código estable.
@freezed
sealed class ForageResource with _$ForageResource {
  /// Crea una entrada de catálogo local o remoto.
  const factory ForageResource({
    required String code,
    required String displayName,
    @Default(true) bool active,
  }) = _ForageResource;
}

/// Catálogo inicial disponible sin conectividad.
// TODO(field-catalog): reemplazar este catálogo inicial por entradas
// sincronizadas desde backend/Brick, conservándolo sólo como fallback offline.
abstract final class InitialForageResources {
  /// Entradas iniciales ordenadas para presentación.
  static const values = <ForageResource>[
    ForageResource(code: 'pasto_natural', displayName: 'Pasto natural'),
    ForageResource(code: 'alfalfa', displayName: 'Alfalfa'),
    ForageResource(code: 'sorgo', displayName: 'Sorgo'),
    ForageResource(code: 'maiz', displayName: 'Maíz'),
    ForageResource(code: 'avena', displayName: 'Avena'),
    ForageResource(code: 'otro', displayName: 'Otro'),
  ];

  /// Busca una etiqueta y conserva legible cualquier código futuro.
  static String displayNameFor(String? code) {
    if (code == null || code.isEmpty) return 'Sin especificar';
    for (final resource in values) {
      if (resource.code == code) return resource.displayName;
    }
    return code.replaceAll('_', ' ');
  }
}
