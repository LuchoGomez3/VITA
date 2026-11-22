import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Sección "Forraje y servicios" del potrero: recurso vigente e historial.
///
/// Cuando el historial está vacío muestra el recurso que trae el lote (lotes
/// sincronizados antes de que existiera el historial).
class LotForageSection extends StatelessWidget {
  /// Crea la sección.
  const LotForageSection({
    required this.periods,
    required this.fallbackResourceCode,
    required this.onAdd,
    required this.onEdit,
    this.hasError = false,
    this.enabled = true,
    super.key,
  });

  /// Períodos vigentes del lote, en cualquier orden.
  final List<LotForagePeriod> periods;

  /// Recurso del lote cuando todavía no hay historial.
  final String? fallbackResourceCode;

  /// Abre la carga de un recurso nuevo.
  final VoidCallback onAdd;

  /// Abre la corrección de un período.
  final ValueChanged<LotForagePeriod> onEdit;

  /// La lectura local del historial falló.
  final bool hasError;

  /// Deshabilita las acciones mientras se guarda.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current = LotForageTimeline.current(periods);
    final history = LotForageTimeline.newestFirst(periods);
    final currentCode = periods.isEmpty ? fallbackResourceCode : current?.resourceCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(FieldStrings.forageSectionTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FieldStrings.currentForageLabel.toUpperCase(),
                style: AppTypography.smallEmphasis.copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  const Icon(Icons.grass_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      currentCode == null ? FieldStrings.noCurrentForage : _label(currentCode, current?.description),
                      style: AppTypography.mediumEmphasis.copyWith(
                        fontWeight: FontWeight.w800,
                        color: currentCode == null ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (current != null) ...[
                const SizedBox(height: 2),
                Text(
                  FieldStrings.forageSince(DateDisplayFormatter.shortDate(current.startDate)),
                  style: AppTypography.formFieldHelper,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppOutlinedButton(
                label: currentCode == null ? FieldStrings.addForageCta : FieldStrings.changeForageCta,
                icon: const Icon(Icons.edit_calendar_outlined),
                onPressed: enabled ? onAdd : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          FieldStrings.forageHistoryTitle.toUpperCase(),
          style: AppTypography.smallEmphasis.copyWith(letterSpacing: 0.6),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (hasError)
          const Text(FieldStrings.forageHistoryError, style: AppTypography.errorBody)
        else if (history.isEmpty)
          const Text(FieldStrings.forageHistoryEmpty, style: AppTypography.formFieldHelper)
        else
          for (final (index, period) in history.indexed)
            _ForagePeriodRow(
              period: period,
              effectiveEnd: LotForageTimeline.effectiveEnd(period, periods),
              isCurrent: identical(period, current),
              isLast: index == history.length - 1,
              onTap: enabled ? () => onEdit(period) : null,
            ),
      ],
    );
  }

  static String _label(String code, String? description) {
    final name = ForageResourceCatalog.displayNameFor(code);
    return description == null ? name : '$name · $description';
  }
}

/// Un punto de la línea de tiempo, igual que el historial de movimientos.
class _ForagePeriodRow extends StatelessWidget {
  const _ForagePeriodRow({
    required this.period,
    required this.effectiveEnd,
    required this.isCurrent,
    required this.isLast,
    required this.onTap,
  });

  final LotForagePeriod period;
  final DateTime? effectiveEnd;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final end = effectiveEnd;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: IntrinsicHeight(
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
                    color: isCurrent ? AppColors.primary : AppColors.backgroundTertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                        spreadRadius: isCurrent ? 2 : 1,
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LotForageSection._label(period.resourceCode, period.description),
                            style: AppTypography.mediumEmphasis.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FieldStrings.forageRange(
                        DateDisplayFormatter.shortDate(period.startDate),
                        end == null ? null : DateDisplayFormatter.shortDate(end),
                      ),
                      style: AppTypography.formFieldHelper,
                    ),
                    if (isCurrent || period.syncStatus != LotSyncStatus.synchronized) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          if (isCurrent)
                            const AppStatusChip(
                              label: FieldStrings.currentForageChip,
                              tone: AppStatusChipTone.success,
                            ),
                          if (period.syncStatus == LotSyncStatus.pending)
                            const AppStatusChip(
                              label: FieldStrings.pendingSyncChip,
                              tone: AppStatusChipTone.warning,
                              showDot: true,
                            ),
                          if (period.syncStatus == LotSyncStatus.rejected)
                            const AppStatusChip(
                              label: FieldStrings.rejectedSyncChip,
                              tone: AppStatusChipTone.error,
                              showDot: true,
                            ),
                        ],
                      ),
                    ],
                    if (period.syncStatus == LotSyncStatus.rejected)
                      Text(
                        FieldStrings.syncErrorMessage(period.syncErrorCode),
                        style: AppTypography.errorBody,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
