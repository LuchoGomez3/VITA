import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';

/// Pestaña "Movim." de la ficha: historial de potreros (diseño
/// `AnimalFichaMovimientos`). Mover animales se hace con el botón flotante.
class AnimalMovementsTab extends StatelessWidget {
  /// Crea la pestaña; el [MovementHistoryCubit] lo provee la ficha.
  const AnimalMovementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MovementHistoryCubit>().state;
    return switch (state) {
      Data<List<MovementHistoryEntry>>(:final data) => ListView(
        // Deja lugar para el botón flotante.
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
        children: [
          Text(
            AnimalMovementStrings.historyTitle(data.length).toUpperCase(),
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (data.isEmpty)
            const Text(AnimalMovementStrings.historyEmpty, style: AppTypography.formFieldHelper)
          else
            for (final (index, entry) in data.indexed)
              _MovementRow(entry: entry, isCurrent: index == 0, isLast: index == data.length - 1),
        ],
      ),
      ResultError<List<MovementHistoryEntry>>() => const Center(
        child: Text(AnimalMovementStrings.historyError, style: AppTypography.pageBodyTitle),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Un punto de la línea de tiempo: "origen → destino", fecha y motivo.
class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.entry, required this.isCurrent, required this.isLast});

  final MovementHistoryEntry entry;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final from = entry.fromLotName ?? AnimalMovementStrings.noOrigin;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.primary, spreadRadius: 2)],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: AppSpacing.xxs),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$from → ${entry.toLotName}${isCurrent ? ' ${AnimalMovementStrings.currentLot}' : ''}',
                          style: AppTypography.mediumEmphasis.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        DateDisplayFormatter.shortDate(entry.occurredAt.toLocal()),
                        style: AppTypography.smallEmphasis.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(entry.reason, style: AppTypography.formFieldHelper),
                  if (entry.isPending) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    const AppStatusChip(
                      label: AnimalMovementStrings.pendingSync,
                      tone: AppStatusChipTone.warning,
                      showDot: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
