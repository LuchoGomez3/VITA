import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/catalogs/feeding_catalog.dart';
import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_feeding_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:go_router/go_router.dart';

/// Pestaña "Alimentación": qué comió el animal, dónde y cuándo.
///
/// Junta el pastoreo, que se deriva de sus movimientos y del recurso de cada
/// potrero, con los suplementos y dietas cargados a mano. Todo sale de SQLite.
class AnimalFeedingTab extends StatelessWidget {
  /// Crea la pestaña; el [AnimalFeedingCubit] lo provee la ficha.
  const AnimalFeedingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnimalFeedingCubit>().state;
    return switch (state) {
      Data<AnimalFeedingHistory>(:final data) when data.entries.isEmpty => _EmptyFeeding(history: data),
      Data<AnimalFeedingHistory>(:final data) => ListView(
        // Deja lugar para el botón flotante.
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
        children: [
          _FeedingSummary(history: data),
          const SizedBox(height: AppSpacing.lg),
          const AnimalFichaSectionTitle(AnimalDetailStrings.feedingHistoryTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final (index, entry) in data.entries.indexed)
            _FeedingRow(entry: entry, isLast: index == data.entries.length - 1),
          // Una nota por cada motivo presente, en el orden en que aparecen.
          for (final reason in {
            for (final entry in data.entries)
              if (entry case GrazingEntry(:final estimateReason?)) estimateReason,
          }) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_estimateHelp(reason), style: AppTypography.formFieldHelper),
          ],
        ],
      ),
      ResultError<AnimalFeedingHistory>() => const Center(
        child: Text(AnimalDetailStrings.feedingError, style: AppTypography.pageBodyTitle),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// "Ahora": dónde pastorea y qué suplementos tiene en curso.
class _FeedingSummary extends StatelessWidget {
  const _FeedingSummary({required this.history});

  final AnimalFeedingHistory history;

  @override
  Widget build(BuildContext context) {
    final grazing = history.currentGrazing;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AnimalDetailStrings.feedingNow.toUpperCase(),
            style: AppTypography.smallEmphasis.copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: AppColors.backgroundSecondaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.grass_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grazing == null ? AnimalDetailStrings.noCurrentGrazing : _grazingTitle(grazing),
                      style: AppTypography.mediumEmphasis.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (grazing != null)
                      Text(
                        AnimalDetailStrings.since(DateDisplayFormatter.shortDate(grazing.from)),
                        style: AppTypography.formFieldHelper,
                      ),
                  ],
                ),
              ),
              if (grazing != null && grazing.estimated) const AppStatusChip(label: AnimalDetailStrings.estimatedChip),
            ],
          ),
          if (grazing != null && grazing.resourceCode == null && history.currentLotId != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _LoadForageButton(lotId: history.currentLotId!),
          ],
          if (history.ongoingSupplements.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Text(
              AnimalDetailStrings.ongoingSupplementsTitle.toUpperCase(),
              style: AppTypography.smallEmphasis.copyWith(letterSpacing: 0.6),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final supplement in history.ongoingSupplements)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Row(
                  children: [
                    const Icon(Icons.grain_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${supplement.foodName} · ${_quantity(supplement)}',
                        style: AppTypography.mediumEmphasis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Un punto de la línea de tiempo, con el mismo dibujo que "Movim.".
class _FeedingRow extends StatelessWidget {
  const _FeedingRow({required this.entry, required this.isLast});

  final FeedingTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isGrazing = entry is GrazingEntry;
    final (title, subtitle, detail, chips) = switch (entry) {
      final GrazingEntry g => (
        _grazingTitle(g),
        _range(g.from, g.to),
        null,
        <Widget>[
          const AppStatusChip(label: AnimalDetailStrings.grazingChip, tone: AppStatusChipTone.success),
          if (g.estimated) const AppStatusChip(label: AnimalDetailStrings.estimatedChip),
          if (g.pending)
            const AppStatusChip(
              label: AnimalDetailStrings.pendingSync,
              tone: AppStatusChipTone.warning,
              showDot: true,
            ),
        ],
      ),
      final SupplementEntry s => (
        s.foodName,
        '${_range(s.from, s.to)} · ${_quantity(s)}',
        [AnimalDetailStrings.feedingPlace(s.lotName), if (s.reason != null) s.reason!].join(' · '),
        <Widget>[
          AppStatusChip(
            label: s.type == FeedingType.diet ? AnimalDetailStrings.dietChip : AnimalDetailStrings.supplementChip,
          ),
          if (s.syncStatus == FeedingSyncStatus.pending)
            const AppStatusChip(
              label: AnimalDetailStrings.pendingSync,
              tone: AppStatusChipTone.warning,
              showDot: true,
            ),
          if (s.syncStatus == FeedingSyncStatus.rejected)
            const AppStatusChip(
              label: AnimalDetailStrings.rejectedChip,
              tone: AppStatusChipTone.error,
              showDot: true,
            ),
        ],
      ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              // Pastoreo en verde; suplementos y dietas en tierra, para que se
              // distingan de un vistazo en la manga.
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isGrazing ? AppColors.primary : AppColors.backgroundTertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                  boxShadow: [
                    BoxShadow(color: isGrazing ? AppColors.primary : AppColors.textSecondary, spreadRadius: 2),
                  ],
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
                  Text(title, style: AppTypography.mediumEmphasis.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.formFieldHelper),
                  if (detail != null && detail.isNotEmpty)
                    Text(detail, style: AppTypography.formFieldHelper.copyWith(color: AppColors.textHint)),
                  const SizedBox(height: AppSpacing.xxs),
                  Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xxs, children: chips),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeeding extends StatelessWidget {
  const _EmptyFeeding({required this.history});

  final AnimalFeedingHistory history;

  @override
  Widget build(BuildContext context) {
    final lotId = history.currentLotId;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grass_outlined, size: 40, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              AnimalDetailStrings.feedingEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              AnimalDetailStrings.feedingEmptyMessage,
              textAlign: TextAlign.center,
              style: AppTypography.pageBodyTitle,
            ),
            if (lotId != null && !history.currentLotHasForage) ...[
              const SizedBox(height: AppSpacing.md),
              _LoadForageButton(lotId: lotId),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadForageButton extends StatelessWidget {
  const _LoadForageButton({required this.lotId});

  final String lotId;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => context.push(AppRoutes.fieldDetailById(lotId)),
    icon: const Icon(Icons.edit_calendar_outlined),
    label: const Text(AnimalDetailStrings.loadLotForageCta),
  );
}

String _grazingTitle(GrazingEntry grazing) => AnimalDetailStrings.grazingTitle(
  grazing.resourceCode == null
      ? AnimalDetailStrings.noForageRecorded
      : [
          ForageResourceCatalog.displayNameFor(grazing.resourceCode),
          if (grazing.resourceDescription != null) grazing.resourceDescription!,
        ].join(' · '),
  grazing.lotName,
);

String _estimateHelp(GrazingEstimateReason reason) => switch (reason) {
  GrazingEstimateReason.noMovements => AnimalDetailStrings.estimatedNoMovements,
  GrazingEstimateReason.beforeFirstMovement => AnimalDetailStrings.estimatedBeforeFirstMovement,
  GrazingEstimateReason.brokenChain => AnimalDetailStrings.estimatedBrokenChain,
  GrazingEstimateReason.lotEditedWithoutMovement => AnimalDetailStrings.estimatedLotEdited,
};

String _range(DateTime from, DateTime? to) {
  final range = AnimalDetailStrings.feedingRange(
    DateDisplayFormatter.shortDate(from),
    to == null ? null : DateDisplayFormatter.shortDate(to),
  );
  final today = DateUtils.dateOnly(DateTime.now());
  final days = (to ?? today).difference(from).inDays + 1;
  return '$range · ${AnimalDetailStrings.feedingDays(days)}';
}

String _quantity(SupplementEntry supplement) => FeedingCatalog.describeQuantity(
  supplement.quantity,
  supplement.unitCode,
  perAnimal: supplement.basis == FeedingQuantityBasis.perAnimalDay,
);
