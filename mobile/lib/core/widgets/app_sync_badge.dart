import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Badge del header con la cantidad de registros pendientes de sincronizar.
///
/// Promovido desde `features/field/presentation/widgets/field_sync_badge.dart`
/// al reutilizarse también en Sanidad (ver `.claude/specs/sanidad.md`), mismo
/// criterio que `AppEarTagBadge`.
class AppSyncBadge extends StatelessWidget {
  /// Crea el badge con el conteo de pendientes.
  const AppSyncBadge({required this.pendingCount, super.key});

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
