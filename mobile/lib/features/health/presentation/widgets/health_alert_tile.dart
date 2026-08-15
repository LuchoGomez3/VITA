import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';

/// Fila de una alerta de la bandeja unificada, con icono y tono según
/// [HealthAlertTone].
class HealthAlertTile extends StatelessWidget {
  /// Crea la fila con la [alert] y la acción disparada al tocarla.
  const HealthAlertTile({required this.alert, required this.onAction, super.key});

  /// Alerta representada.
  final HealthAlertMock alert;

  /// Acción disparada al tocar el link de la alerta.
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (alert.tone) {
      HealthAlertTone.danger => (Icons.error, AppColors.error),
      HealthAlertTone.warn => (Icons.warning_amber_rounded, AppColors.warning),
      HealthAlertTone.info => (Icons.info, AppColors.primary),
    };

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: AppTypography.secondaryEmphasis),
                const SizedBox(height: AppSpacing.xxs),
                Text(alert.subtitle, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAction,
            child: Text(
              alert.actionLabel,
              style: AppTypography.inlinePrimaryLink.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
