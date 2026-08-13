import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Badge del header con la cantidad de registros pendientes de sincronizar.
class FieldSyncBadge extends StatelessWidget {
  /// Crea el badge con el conteo de pendientes.
  const FieldSyncBadge({required this.pendingCount, super.key});

  /// Cantidad de registros pendientes de sincronización.
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xxs),
          Text('$pendingCount', style: AppTypography.smallEmphasis),
        ],
      ),
    );
  }
}
