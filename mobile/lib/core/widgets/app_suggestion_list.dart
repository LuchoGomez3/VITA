import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Construye el contenido particular de cada resultado sugerido.
typedef AppSuggestionItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
    );

/// Permite conservar una clave estable para cada resultado sugerido.
typedef AppSuggestionItemKeyBuilder<T> = Key? Function(T item);

/// Lista desplegable compartida para resultados de búsqueda seleccionables.
class AppSuggestionList<T> extends StatelessWidget {
  /// Crea una lista compacta con la apariencia común de los autocompletados.
  const AppSuggestionList({
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    super.key,
    this.itemKeyBuilder,
  });

  /// Resultados que se muestran en el orden recibido.
  final List<T> items;

  /// Construye el contenido específico de cada resultado.
  final AppSuggestionItemBuilder<T> itemBuilder;

  /// Informa qué resultado seleccionó el usuario.
  final ValueChanged<T> onSelected;

  /// Genera claves estables cuando la pantalla necesita localizar una fila.
  final AppSuggestionItemKeyBuilder<T>? itemKeyBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            InkWell(
              key: itemKeyBuilder?.call(items[index]),
              onTap: () => onSelected(items[index]),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: itemBuilder(context, items[index]),
              ),
            ),
            if (index < items.length - 1) const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}
