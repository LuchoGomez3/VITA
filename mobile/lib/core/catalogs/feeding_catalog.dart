import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';

/// Catálogos y formatos de alimentación compartidos por la ficha del animal y
/// el registro de alimentación. Los códigos coinciden con backend (adr-0015).
abstract final class FeedingCatalog {
  /// Categorías de alimento, en orden de presentación.
  static const categories = <ForageResourceOption>[
    ForageResourceOption('grano', 'Grano'),
    ForageResourceOption('concentrado', 'Concentrado / núcleo'),
    ForageResourceOption('heno', 'Heno / rollo'),
    ForageResourceOption('silaje', 'Silaje'),
    ForageResourceOption('subproducto', 'Subproducto'),
    ForageResourceOption('mineral', 'Sales / minerales'),
    ForageResourceOption('otro', 'Otro'),
  ];

  /// Unidades, en orden de presentación.
  static const units = <ForageResourceOption>[
    ForageResourceOption('kg', 'kg'),
    ForageResourceOption('g', 'g'),
    ForageResourceOption('l', 'litros'),
    ForageResourceOption('fardo', 'fardos'),
    ForageResourceOption('rollo', 'rollos'),
    ForageResourceOption('bolsa', 'bolsas'),
  ];

  /// Etiqueta de una categoría.
  static String categoryLabel(String code) => _label(categories, code);

  /// Etiqueta de una unidad.
  static String unitLabel(String code) => _label(units, code);

  /// "2,5 kg por animal por día" en forma compacta: "2,5 kg/animal/día".
  static String describeQuantity(String quantity, String unitCode, {required bool perAnimal}) {
    final value = num.tryParse(quantity);
    final text = value == null
        ? quantity
        : (value == value.roundToDouble() ? value.toInt().toString() : value.toString()).replaceAll('.', ',');
    return '$text ${unitLabel(unitCode)}/${perAnimal ? 'animal/día' : 'día (grupo)'}';
  }

  static String _label(List<ForageResourceOption> options, String code) {
    for (final option in options) {
      if (option.code == code) return option.displayName;
    }
    return code;
  }
}
