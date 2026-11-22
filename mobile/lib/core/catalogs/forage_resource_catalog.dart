/// Opción del catálogo de recursos forrajeros: código estable y etiqueta.
class ForageResourceOption {
  /// Crea una entrada del catálogo.
  const ForageResourceOption(this.code, this.displayName);

  /// Código acordado con backend (`RecursoForrajero`).
  final String code;

  /// Texto visible para el productor.
  final String displayName;
}

/// Catálogo de recursos forrajeros disponible sin conectividad.
///
/// Vive en `core` porque lo usan el potrero (historial de recursos) y la
/// alimentación del animal (pastoreo), y ninguna feature importa a la otra.
/// Los códigos coinciden con `RecursoForrajero` del backend (adr-0015).
abstract final class ForageResourceCatalog {
  /// Entradas ordenadas para presentación; "Otro" va al final.
  static const values = <ForageResourceOption>[
    ForageResourceOption('pasto_natural', 'Pasto natural'),
    ForageResourceOption('pastura_consociada', 'Pastura consociada'),
    ForageResourceOption('alfalfa', 'Alfalfa'),
    ForageResourceOption('festuca', 'Festuca'),
    ForageResourceOption('agropiro', 'Agropiro'),
    ForageResourceOption('raigras', 'Raigrás'),
    ForageResourceOption('gatton_panic', 'Gatton panic'),
    ForageResourceOption('grama_rhodes', 'Grama Rhodes'),
    ForageResourceOption('avena', 'Avena'),
    ForageResourceOption('cebada', 'Cebada'),
    ForageResourceOption('centeno', 'Centeno'),
    ForageResourceOption('triticale', 'Triticale'),
    ForageResourceOption('verdeo_verano', 'Verdeo de verano'),
    ForageResourceOption('sorgo', 'Sorgo'),
    ForageResourceOption('maiz', 'Maíz'),
    ForageResourceOption('moha', 'Moha'),
    ForageResourceOption('rastrojo_maiz', 'Rastrojo de maíz'),
    ForageResourceOption('rastrojo_sorgo', 'Rastrojo de sorgo'),
    ForageResourceOption('rastrojo_soja', 'Rastrojo de soja'),
    ForageResourceOption('otro', 'Otro'),
  ];

  /// Código que exige una descripción libre.
  static const otherCode = 'otro';

  /// Busca una etiqueta y conserva legible cualquier código futuro.
  static String displayNameFor(String? code) {
    if (code == null || code.isEmpty) return 'Sin especificar';
    for (final resource in values) {
      if (resource.code == code) return resource.displayName;
    }
    return code.replaceAll('_', ' ');
  }
}
