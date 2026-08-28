import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';

/// Detalle durable de un lote recuperado desde SQLite.
class FieldDetailPage extends StatelessWidget {
  /// Crea la ficha local del lote solicitado.
  const FieldDetailPage({
    required this.lotId,
    required this.getLot,
    super.key,
  });

  /// UUID generado en el dispositivo.
  final String lotId;

  /// Consulta de dominio inyectada por composición.
  final GetLotUseCase getLot;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Lot>>(
      future: getLot(lotId),
      builder: (context, snapshot) {
        final result = snapshot.data;
        final title = switch (result) {
          Success<Lot>(:final data) => data.name,
          _ => FieldStrings.lotDetailTitle,
        };
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            child: switch (result) {
              null => const Center(child: CircularProgressIndicator()),
              Failure<Lot>(:final error) => Center(child: Text(error.message)),
              Success<Lot>(:final data) => _LotDetailBody(lot: data),
              _ => const Center(child: Text(FieldStrings.localLotsLoadError)),
            },
          ),
        );
      },
    );
  }
}

class _LotDetailBody extends StatelessWidget {
  const _LotDetailBody({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    const validator = LocalLotBoundaryValidator();
    final area = validator.validate(lot.boundary).estimatedAreaSquareUnits;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SizedBox(
          height: 260,
          child: LotOverviewCanvas(lots: [lot], onLotSelected: (_) {}),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: FieldStrings.lotVerticesLabel,
                value: '${lot.boundary.vertices.length}',
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: FieldStrings.relativeAreaLabel,
                value: '${area.toStringAsFixed(0)} ${FieldStrings.relativeAreaUnit}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const AppStatusChip(
          label: FieldStrings.savedOnDeviceStatus,
          tone: AppStatusChipTone.success,
          showDot: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppInfoCell(
          label: FieldStrings.createdAtLabel,
          value: _formatDate(lot.createdAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInfoCell(
          label: FieldStrings.updatedAtLabel,
          value: _formatDate(lot.updatedAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
