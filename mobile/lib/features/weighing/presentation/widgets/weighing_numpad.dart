import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';

/// Numpad propio (no el teclado del sistema) para ingresar el peso manual.
///
/// Grid de 3 columnas: `1 2 3 / 4 5 6 / 7 8 9 / , 0 ⌫`, con coma como
/// separador decimal (formato es-AR).
class WeighingNumpad extends StatelessWidget {
  /// Crea el numpad, notificando cada tecla presionada por [onKeyPressed].
  const WeighingNumpad({required this.onKeyPressed, super.key});

  /// Callback invocado con la tecla presionada: un dígito, la coma decimal o
  /// [WeighingStrings.numpadBackspaceLabel] para borrar.
  final ValueChanged<String> onKeyPressed;

  static const List<String> _keys = [
    '1', '2', '3', //
    '4', '5', '6',
    '7', '8', '9',
    WeighingStrings.numpadDecimalSeparator, '0', WeighingStrings.numpadBackspaceLabel,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 1.6,
      children: [for (final key in _keys) _NumpadKey(label: key, onTap: () => onKeyPressed(key))],
    );
  }
}

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Center(
          child: Text(label, style: AppTypography.pageBodyTitle),
        ),
      ),
    );
  }
}
