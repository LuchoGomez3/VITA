import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';

/// Método de captura seleccionable en [WeighingTabSelector].
enum WeighingCaptureTab {
  /// Captura por balanza Bluetooth.
  bluetooth,

  /// Captura manual con numpad.
  manual,
}

/// Selector segmentado de método de captura: Bluetooth / Manual / Por foto.
///
/// La tab "Por foto" se muestra deshabilitada ("Próximamente"): estimación de
/// peso por imagen es de `ai_models/`, fuera del MVP (ver CLAUDE.md y
/// `.claude/specs/pesaje-en-manga.md`).
class WeighingTabSelector extends StatelessWidget {
  /// Crea el selector marcando cuál tab está activa.
  const WeighingTabSelector({required this.activeTab, required this.onChanged, super.key});

  /// Tab actualmente seleccionada.
  final WeighingCaptureTab activeTab;

  /// Callback invocado al elegir Bluetooth o Manual.
  final ValueChanged<WeighingCaptureTab> onChanged;

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
                label: WeighingStrings.bluetoothTab,
                isActive: activeTab == WeighingCaptureTab.bluetooth,
                onTap: () => onChanged(WeighingCaptureTab.bluetooth),
              ),
            ),
            Expanded(
              child: _segment(
                label: WeighingStrings.manualTab,
                isActive: activeTab == WeighingCaptureTab.manual,
                onTap: () => onChanged(WeighingCaptureTab.manual),
              ),
            ),
            Expanded(
              child: _segment(
                label: WeighingStrings.photoTab,
                caption: WeighingStrings.photoTabComingSoon,
                isActive: false,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    String? caption,
  }) {
    final isDisabled = onTap == null;

    return Material(
      color: isActive ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.smallEmphasis.copyWith(
                  color: isDisabled
                      ? AppColors.textHint
                      : (isActive ? AppColors.textPrimary : AppColors.textSecondary),
                ),
              ),
              if (caption != null)
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: AppTypography.formFieldHelper.copyWith(color: AppColors.textHint, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
