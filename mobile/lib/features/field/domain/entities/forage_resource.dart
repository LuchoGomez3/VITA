import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';

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

/// Catálogo disponible sin conectividad, tomado del catálogo compartido.
abstract final class InitialForageResources {
  /// Entradas ordenadas para presentación.
  static final values = <ForageResource>[
    for (final option in ForageResourceCatalog.values)
      ForageResource(code: option.code, displayName: option.displayName),
  ];

  /// Busca una etiqueta y conserva legible cualquier código futuro.
  static String displayNameFor(String? code) => ForageResourceCatalog.displayNameFor(code);
}
