import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';

/// Selector del establecimiento activo en Inicio.
///
/// Se muestra como la línea `Resumen productivo de <establecimiento>`; al
/// tocarla despliega debajo una lista con "Todos los establecimientos", cada
/// establecimiento disponible y, al final, la opción de crear uno nuevo. Usa
/// `MenuAnchor` en vez de `DropdownButton` porque "Nuevo establecimiento" es
/// una acción, no un valor seleccionable.
class HomeEstablishmentSelect extends StatelessWidget {
  /// Crea el selector con el establecimiento activo y sus callbacks.
  const HomeEstablishmentSelect({
    required this.establishments,
    required this.selectedEstablishmentId,
    required this.onSelected,
    required this.onCreateEstablishment,
    this.controller,
    super.key,
  });

  /// Establecimientos disponibles, indexados por ID.
  final Map<String, EstablishmentMembership> establishments;

  /// ID activo; `null` representa todos los establecimientos.
  final String? selectedEstablishmentId;

  /// Informa la opción elegida; `null` representa todos.
  final ValueChanged<String?> onSelected;

  /// Abre el alta de un establecimiento nuevo.
  final VoidCallback onCreateEstablishment;

  /// Permite abrir la lista desde afuera (p. ej. desde un aviso del dashboard).
  final MenuController? controller;

  @override
  Widget build(BuildContext context) {
    final selectedName = establishments[selectedEstablishmentId]?.name ?? HomeStrings.allEstablishments;

    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: controller,
        alignmentOffset: const Offset(0, AppSpacing.xxs),
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.backgroundTertiary),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: AppSpacing.xxs)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: const BorderSide(color: AppColors.textSecondary),
            ),
          ),
        ),
        menuChildren: [
          _EstablishmentMenuItem(
            width: constraints.maxWidth,
            label: HomeStrings.allEstablishments,
            isSelected: selectedEstablishmentId == null,
            onPressed: () => onSelected(null),
          ),
          ...establishments.entries.map(
            (entry) => _EstablishmentMenuItem(
              width: constraints.maxWidth,
              label: entry.value.name,
              isSelected: entry.key == selectedEstablishmentId,
              onPressed: () => onSelected(entry.key),
            ),
          ),
          SizedBox(
            width: constraints.maxWidth,
            child: Divider(
              height: AppSpacing.xs,
              indent: AppSpacing.sm,
              endIndent: AppSpacing.sm,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          _EstablishmentMenuItem(
            width: constraints.maxWidth,
            label: HomeStrings.createEstablishmentOption,
            icon: Icons.add,
            onPressed: onCreateEstablishment,
          ),
        ],
        builder: (context, menu, child) => InkWell(
          onTap: () => menu.isOpen ? menu.close() : menu.open(),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${HomeStrings.establishmentPrefix} $selectedName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.smallEmphasis,
                  ),
                ),
                AnimatedRotation(
                  turns: menu.isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstablishmentMenuItem extends StatelessWidget {
  const _EstablishmentMenuItem({
    required this.width,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
    this.icon,
  });

  /// Ancho de la línea del selector: la lista se alinea exactamente debajo.
  final double width;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final IconData? icon;

  static const _style = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(0, 40)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
    foregroundColor: WidgetStatePropertyAll(AppColors.textSecondary),
    iconColor: WidgetStatePropertyAll(AppColors.textSecondary),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MenuItemButton(
        onPressed: onPressed,
        style: _style,
        leadingIcon: icon == null ? null : Icon(icon, size: 18),
        trailingIcon: isSelected ? const Icon(Icons.check, size: 18) : null,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.smallEmphasis,
        ),
      ),
    );
  }
}
