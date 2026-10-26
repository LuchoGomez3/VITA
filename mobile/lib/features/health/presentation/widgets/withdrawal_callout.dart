import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Callout de alerta para el período de carencia de un tratamiento.
///
/// El período de carencia (withdrawal period) es un módulo crítico según
/// CLAUDE.md (85% de cobertura exigida cuando se conecte a backend): acá
/// solo se maqueta el mensaje, el cálculo real queda para Etapa 3 (ver
/// `.claude/specs/sanidad.md`).
class WithdrawalCallout extends StatelessWidget {
  /// Crea el callout con el [message] de carencia ya formateado.
  const WithdrawalCallout({required this.message, super.key});

  /// Mensaje de carencia mostrado dentro del callout.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTypography.errorBody),
          ),
        ],
      ),
    );
  }
}
