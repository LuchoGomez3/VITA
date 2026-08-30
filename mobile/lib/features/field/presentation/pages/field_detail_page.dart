import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/forage_resource.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_detail_cubit.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_edit_dialog.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_movement_dialog.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';
import 'package:go_router/go_router.dart';

/// Fábrica inyectable del estado de detalle.
typedef LotDetailCubitFactory = LotDetailCubit Function();

/// Ficha offline de un lote y sus animales actuales.
class FieldDetailPage extends StatelessWidget {
  /// Crea la pantalla con sus dependencias resueltas en composición.
  const FieldDetailPage({required this.createCubit, super.key});

  /// Construye el Cubit propietario de la ficha.
  final LotDetailCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: BlocListener<LotDetailCubit, LotDetailState>(
        listenWhen: (previous, current) => previous.isDeleted != current.isDeleted && current.isDeleted,
        listener: (context, _) => context.pop(true),
        child: const _FieldDetailView(),
      ),
    );
  }
}

class _FieldDetailView extends StatelessWidget {
  const _FieldDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LotDetailCubit, LotDetailState>(
      builder: (context, state) {
        final lot = state.lot;
        return Scaffold(
          appBar: AppBar(
            title: Text(lot?.name ?? FieldStrings.lotDetailTitle),
            actions: lot == null
                ? null
                : [
                    IconButton(
                      tooltip: FieldStrings.editLotCta,
                      onPressed: state.isSaving ? null : () => _edit(context, lot),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: FieldStrings.deleteLotCta,
                      onPressed: state.isSaving ? null : () => _delete(context),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
          ),
          body: SafeArea(
            child: switch (state.loadState) {
              Initial<void>() || Loading<void>() => const Center(child: CircularProgressIndicator()),
              ResultError<void>(:final error) => _ErrorBody(message: error.message),
              Data<void>() => state.isDeleted ? const SizedBox.shrink() : _LotDetailBody(state: state),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, Lot lot) async {
    final input = await showDialog<LotEditInput>(
      context: context,
      builder: (_) => LotEditDialog(lot: lot),
    );
    if (input == null || !context.mounted) return;
    await context.read<LotDetailCubit>().update(
      name: input.name,
      surfaceTenths: input.surfaceTenths,
      forageResourceCode: input.forageResourceCode,
      hasWater: input.hasWater,
      status: input.status,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(FieldStrings.deleteLotDialogTitle),
        content: const Text(FieldStrings.deleteLotDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(FieldStrings.cancelClearBoundaryCta),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(FieldStrings.deleteLotCta),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await context.read<LotDetailCubit>().delete();
    }
  }
}

class _LotDetailBody extends StatelessWidget {
  const _LotDetailBody({required this.state});

  final LotDetailState state;

  @override
  Widget build(BuildContext context) {
    final lot = state.lot!;
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
                label: FieldStrings.surfaceDetailLabel,
                value: '${lot.surfaceHectares.toStringAsFixed(1)} ha',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppInfoCell(
                label: FieldStrings.headCountDetailLabel,
                value: '${state.animals.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInfoCell(
          label: FieldStrings.forageResourceLabel,
          value: InitialForageResources.displayNameFor(lot.forageResourceCode),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInfoCell(
          label: FieldStrings.waterAvailabilityLabel,
          value: lot.hasWater ? FieldStrings.waterAvailable : FieldStrings.waterUnavailable,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInfoCell(
          label: FieldStrings.lotStatusLabel,
          value: FieldStrings.statusName(lot.status),
        ),
        if (state.mutationErrorMessage case final message?) ...[
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.errorBody),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          FieldStrings.animalsSectionTitle(state.animals.length),
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.animals.isNotEmpty && state.availableDestinations.isNotEmpty) ...[
          AppFilledButton(
            label: FieldStrings.moveAnimalsCta,
            onPressed: state.isSaving ? null : () => _moveAnimals(context),
          ),
          const SizedBox(height: AppSpacing.sm),
        ] else if (state.animals.isNotEmpty) ...[
          const Text(FieldStrings.noMovementDestinationMessage),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.animals.isEmpty)
          const Text(FieldStrings.noAnimalsInLotMessage)
        else
          for (final animal in state.animals)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.pets_outlined),
              title: Text(
                animal.visualTag.isEmpty ? animal.rfidTagNumber : animal.visualTag,
              ),
              subtitle: Text(
                '${animal.categoryName} · RFID ${animal.rfidTagNumber}',
              ),
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

  Future<void> _moveAnimals(BuildContext context) async {
    final input = await showDialog<LotMovementInput>(
      context: context,
      builder: (_) => LotMovementDialog(
        animals: state.animals,
        destinations: state.availableDestinations,
      ),
    );
    if (input == null || !context.mounted) return;
    await context.read<LotDetailCubit>().moveAnimals(
      animalIds: input.animalIds,
      destinationLotId: input.destinationLotId,
      occurredAt: input.occurredAt,
      reason: input.reason,
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: AppSpacing.md),
          AppFilledButton(
            label: FieldStrings.retryCta,
            onPressed: context.read<LotDetailCubit>().load,
          ),
        ],
      ),
    ),
  );
}
