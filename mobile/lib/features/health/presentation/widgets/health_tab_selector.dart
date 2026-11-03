import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';

/// Sección seleccionable en [HealthTabSelector].
enum HealthTab {
  /// Campañas de vacunación.
  vaccinations,

  /// Tratamientos con período de carencia.
  treatments,

  /// Bandeja unificada de alertas.
  alerts,
}

/// Selector segmentado de las 3 tabs de Sanidad: Vacunaciones / Tratamientos
/// / Alertas. Mismo patrón visual que `WeighingTabSelector`, sin tabs
/// deshabilitadas.
class HealthTabSelector extends StatelessWidget {
  /// Crea el selector marcando cuál tab está activa.
  const HealthTabSelector({required this.activeTab, required this.onChanged, super.key});

  /// Tab actualmente seleccionada.
  final HealthTab activeTab;

  /// Callback invocado al elegir una tab.
  final ValueChanged<HealthTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          children: [
            Expanded(
              child: _segment(
                label: HealthStrings.vaccinationsTab,
                isActive: activeTab == HealthTab.vaccinations,
                onTap: () => onChanged(HealthTab.vaccinations),
              ),
            ),
            Expanded(
              child: _segment(
                label: HealthStrings.treatmentsTab,
                isActive: activeTab == HealthTab.treatments,
                onTap: () => onChanged(HealthTab.treatments),
              ),
            ),
            Expanded(
              child: _segment(
                label: HealthStrings.alertsTab,
                isActive: activeTab == HealthTab.alerts,
                onTap: () => onChanged(HealthTab.alerts),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({required String label, required bool isActive, required VoidCallback onTap}) {
    return Material(
      color: isActive ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.smallEmphasis.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
