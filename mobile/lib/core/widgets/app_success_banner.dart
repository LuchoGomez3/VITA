import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Un banner reutilizable para mostrar mensajes de éxito o validación positiva.
class AppSuccessBanner extends StatelessWidget {
  /// Creates a success banner with [message].
  const AppSuccessBanner({
    required this.message,
    super.key,
  });

  /// El mensaje que se mostrará en el banner.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPositiveContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderPositiveContainer),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.checkIcon,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.positiveText,
            ),
          ),
        ],
      ),
    );
  }
}
