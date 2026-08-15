import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/mock/sync_status_mock.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_conflict_card.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_progress_banner.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_queue_row.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de estado de sincronización: progreso, cola de operaciones y
/// resolución de conflictos last-write-wins.
///
/// Réplica visual estática del diseño `SyncScreen` (ver
/// `.claude/specs/sincronizacion.md`); todos los datos son mock. El refresh
/// manual y la resolución de conflictos no invocan al motor de sync real
/// todavía — `features/sync/` sólo tiene hoy la sincronización inicial
/// posterior al login, sin cola de operaciones ni entidad de conflicto.
class SyncStatusPage extends StatelessWidget {
  /// Crea la pantalla de estado de sincronización.
  const SyncStatusPage({super.key});

  void _showOutOfScopeSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(SyncStatusStrings.outOfScopeMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SyncStatusHeader(onRefresh: () => _showOutOfScopeSnackBar(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                children: [
                  SyncProgressBanner(
                    done: syncStatusInProgressCount,
                    total: syncStatusPendingCount,
                    connectionLabel: syncStatusConnectionLabel,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(SyncStatusStrings.queueSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  for (final entry in syncQueueEntriesMock) ...[
                    SyncQueueRow(entry: entry),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    SyncStatusStrings.conflictsSectionTitle(syncConflictsMock.length),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final conflict in syncConflictsMock)
                    SyncConflictCard(
                      conflict: conflict,
                      onKeepServer: () => _showOutOfScopeSnackBar(context),
                      onApplyMine: () => _showOutOfScopeSnackBar(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusHeader extends StatelessWidget {
  const _SyncStatusHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SyncStatusStrings.title, style: AppTypography.appBarTitle),
                Text(
                  SyncStatusStrings.lastSyncSubtitle(syncStatusLastSyncLabel, syncStatusPendingCount),
                  style: AppTypography.formFieldHelper,
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.backgroundSecondary, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: SyncStatusStrings.refreshTooltip,
              onPressed: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
