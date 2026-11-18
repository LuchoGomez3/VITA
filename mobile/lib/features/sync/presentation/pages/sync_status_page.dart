import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_progress_banner.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_queue_row.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de estado de sincronización: muestra en vivo la cola de
/// operaciones registradas en el teléfono que todavía no llegaron al backend,
/// los registros que el backend rechazó y lo que se envió en esta sesión.
///
/// Lee solo SQLite local, así que funciona igual sin conexión. Ver
/// `.claude/specs/sincronizacion.md`.
class SyncStatusPage extends StatelessWidget {
  /// Crea la pantalla con la fábrica de su cubit.
  const SyncStatusPage({required this.createCubit, super.key});

  /// Fábrica del cubit; la pantalla lo cierra al salir.
  final SyncQueueCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(),
      child: const _SyncStatusView(),
    );
  }
}

class _SyncStatusView extends StatelessWidget {
  const _SyncStatusView();

  Future<void> _synchronizeNow(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final synchronized = await context.read<SyncQueueCubit>().synchronizeNow();
    if (!synchronized) {
      messenger.showSnackBar(const SnackBar(content: Text(SyncStatusStrings.manualSyncFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SyncQueueCubit, SyncQueueViewState>(
          builder: (context, state) {
            final snapshot = state.snapshot;
            return Column(
              children: [
                _SyncStatusHeader(
                  subtitle: snapshot == null
                      ? SyncStatusStrings.loadingSubtitle
                      : SyncStatusStrings.pendingSubtitle(snapshot.pendingCount),
                  isSynchronizing: state.isSynchronizing,
                  onRefresh: () => _synchronizeNow(context),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                    children: [
                      if (state.error != null) ...[
                        const _ReadErrorNotice(),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (snapshot == null && state.error == null)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snapshot != null) ...[
                        SyncProgressBanner(
                          pendingCount: snapshot.pendingCount,
                          isSending: snapshot.isSending,
                          isOnline: state.isOnline,
                        ),
                        if (state.rejected.isNotEmpty) ...[
                          const _SectionHeader(
                            title: SyncStatusStrings.rejectedSectionTitle,
                            detail: SyncStatusStrings.rejectedSectionDetail,
                          ),
                          for (final record in state.rejected) ...[
                            SyncRejectedRow(key: ValueKey('rejected-${record.localId}'), record: record),
                            const SizedBox(height: AppSpacing.xxs),
                          ],
                        ],
                        if (!snapshot.isEmpty) ...[
                          const _SectionHeader(title: SyncStatusStrings.queueSectionTitle),
                          for (final operation in snapshot.operations) ...[
                            SyncQueueRow(key: ValueKey(operation.queueId), operation: operation),
                            const SizedBox(height: AppSpacing.xxs),
                          ],
                        ],
                      ],
                      if (state.recentlySent.isNotEmpty) ...[
                        const _SectionHeader(
                          title: SyncStatusStrings.sentSectionTitle,
                          detail: SyncStatusStrings.sentSectionDetail,
                        ),
                        for (final (index, record) in state.recentlySent.indexed) ...[
                          SyncSentRow(key: ValueKey('sent-$index-${record.localId}'), record: record),
                          const SizedBox(height: AppSpacing.xxs),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (detail != null) Text(detail, style: AppTypography.formFieldHelper),
        ],
      ),
    );
  }
}

class _ReadErrorNotice extends StatelessWidget {
  const _ReadErrorNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                SyncStatusStrings.readError,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusHeader extends StatelessWidget {
  const _SyncStatusHeader({
    required this.subtitle,
    required this.isSynchronizing,
    required this.onRefresh,
  });

  final String subtitle;
  final bool isSynchronizing;
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
                const Text(SyncStatusStrings.title, style: AppTypography.appBarTitle),
                Text(subtitle, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.backgroundSecondary, shape: BoxShape.circle),
            child: IconButton(
              icon: isSynchronizing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: SyncStatusStrings.refreshTooltip,
              onPressed: isSynchronizing ? null : onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
