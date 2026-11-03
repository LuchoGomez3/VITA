import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Selector de establecimiento de la cabecera (diseño `AppHeader` → `estab-picker`).
///
/// Píldora con el nombre del establecimiento elegido y una flecha; al tocarla
/// abre una hoja con los establecimientos del usuario. `null` representa
/// "todos los establecimientos".
class AppEstablishmentPicker extends StatelessWidget {
  /// Crea el selector.
  const AppEstablishmentPicker({
    required this.establishments,
    required this.selectedId,
    required this.onSelected,
    required this.allLabel,
    super.key,
  });

  /// Establecimientos del usuario.
  final List<EstablishmentMembership> establishments;

  /// Establecimiento elegido, o `null` para "todos".
  final String? selectedId;

  /// Se llama con el id elegido, o `null` para "todos".
  final ValueChanged<String?> onSelected;

  /// Texto de la opción "todos los establecimientos".
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final selectedName = establishments
        .where((establishment) => establishment.id == selectedId)
        .map((establishment) => establishment.name)
        .firstOrNull;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      // La cabecera de la app es beige (no clara como en el diseño): la
      // píldora va en blanco con borde para que se distinga.
      child: Material(
        color: AppColors.surface,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: establishments.isEmpty ? null : () => _open(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    selectedName ?? allLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final options = <(String?, String)>[
      if (establishments.length > 1) (null, allLabel),
      for (final establishment in establishments) (establishment.id, establishment.name),
    ];
    final chosen = await showModalBottomSheet<(String?,)>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final (id, name) in options)
              ListTile(
                title: Text(name, style: AppTypography.mediumEmphasis),
                trailing: id == selectedId ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.of(sheetContext).pop((id,)),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      onSelected(chosen.$1);
    }
  }
}
