import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_density_legend.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_paddock_mosaic.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_sync_badge.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_view_toggle.dart';

/// Vista de mapa del campo: potreros coloreados por densidad de carga.
///
/// Réplica visual estática, sin SDK de mapas ni GPS real (ver
/// `.claude/specs/campo-y-potreros.md`).
class FieldMapPage extends StatelessWidget {
  /// Crea la pantalla de mapa de potreros.
  const FieldMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(
        title: FieldStrings.title,
        headline: FieldStrings.establishmentTitle,
        actions: [FieldSyncBadge(pendingCount: FieldStrings.pendingSyncCount)],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: FieldPaddockMosaic(paddocks: paddocksMock),
            ),
            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              child: _PaddockSummaryChip(),
            ),
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: FieldDensityLegend(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Center(child: FieldViewToggle(isMapActive: true)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaddockSummaryChip extends StatelessWidget {
  const _PaddockSummaryChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _kpi(FieldStrings.paddocksKpiLabel, '$paddocksTotalCount'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SizedBox(height: 24, width: 1, child: ColoredBox(color: AppColors.border)),
            ),
            _kpi(FieldStrings.headCountKpiLabel, '$paddocksTotalHeadCount'),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint)),
        Text(value, style: AppTypography.formFieldValueEmphasis),
      ],
    );
  }
}
