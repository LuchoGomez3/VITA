import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';

/// Encabezado de Inicio que despliega el selector de establecimientos.
class HomeExpandableHeader extends StatelessWidget {
  /// Crea el encabezado con su selección visual y callbacks.
  const HomeExpandableHeader({
    required this.greeting,
    required this.isExpanded,
    required this.highlightedEstablishmentId,
    required this.onToggle,
    required this.onSelected,
    required this.onIdentifyAnimal,
    super.key,
  });

  /// Saludo mostrado como título principal.
  final String greeting;

  /// Indica si las opciones están visibles.
  final bool isExpanded;

  /// ID resaltado durante la transición; `null` representa todos.
  final String? highlightedEstablishmentId;

  /// Alterna la expansión del encabezado.
  final VoidCallback onToggle;

  /// Informa la opción tocada.
  final ValueChanged<String?> onSelected;

  /// Abre el flujo de identificacion RFID para el establecimiento activo.
  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        final selectedEstablishmentName = state.establishments[highlightedEstablishmentId];
        final selectedName = selectedEstablishmentName ?? HomeStrings.allEstablishments;

        return Material(
          color: AppColors.backgroundTertiary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.lg),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            bottom: false,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderToolbar(
                    greeting: greeting,
                    selectedName: selectedName,
                    isExpanded: isExpanded,
                    onToggle: onToggle,
                    onIdentifyAnimal: onIdentifyAnimal,
                  ),
                  if (isExpanded)
                    _EstablishmentOptions(
                      establishments: state.establishments,
                      highlightedEstablishmentId: highlightedEstablishmentId,
                      onSelected: onSelected,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderToolbar extends StatelessWidget {
  const _HeaderToolbar({
    required this.greeting,
    required this.selectedName,
    required this.isExpanded,
    required this.onToggle,
    required this.onIdentifyAnimal,
  });

  final String greeting;
  final String selectedName;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTypography.appBarTitle),
                const SizedBox(height: AppSpacing.xxs),
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
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
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 280),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: HomeStrings.identifyAnimalTooltip,
            onPressed: onIdentifyAnimal,
            icon: const Icon(Icons.bluetooth),
          ),
        ],
      ),
    );
  }
}

class _EstablishmentOptions extends StatelessWidget {
  const _EstablishmentOptions({
    required this.establishments,
    required this.highlightedEstablishmentId,
    required this.onSelected,
  });

  final Map<String, String> establishments;
  final String? highlightedEstablishmentId;
  final ValueChanged<String?> onSelected;

  static const _optionHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final entries = establishments.entries.toList();
    final selectedIndex = highlightedEstablishmentId == null
        ? 0
        : entries.indexWhere(
                (entry) => entry.key == highlightedEstablishmentId,
              ) +
              1;

    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxs,
            ),
            child: Text(
              HomeStrings.establishmentSelectionPrompt,
              style: AppTypography.smallEmphasis,
            ),
          ),
        ),
        Stack(
          children: [
            Positioned(
              top: selectedIndex * _optionHeight,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              height: _optionHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _EstablishmentOption(
                  label: HomeStrings.allEstablishments,
                  onTap: () => onSelected(null),
                ),
                ...entries.map(
                  (entry) => _EstablishmentOption(
                    label: entry.value,
                    onTap: () => onSelected(entry.key),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _EstablishmentOption extends StatelessWidget {
  const _EstablishmentOption({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        height: _EstablishmentOptions._optionHeight,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
