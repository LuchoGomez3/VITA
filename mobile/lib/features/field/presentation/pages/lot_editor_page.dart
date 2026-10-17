import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/forage_resource.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/geographic_lot_editor.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_draft_summary.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_editor_toolbar.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_validation_message.dart';
import 'package:go_router/go_router.dart';

/// Fábrica inyectable del BLoC del editor local.
typedef LotEditorBlocFactory = LotEditorBloc Function();

/// Pantalla de Fase 1 para delimitar un lote sin persistencia ni mapa base.
class LotEditorPage extends StatelessWidget {
  /// Crea la pantalla con sus dependencias resueltas fuera de presentation.
  const LotEditorPage({required this.createBloc, super.key});

  /// Crea el BLoC cuando la ruta abre la pantalla.
  final LotEditorBlocFactory createBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: BlocListener<LotEditorBloc, LotEditorState>(
        listenWhen: (previous, current) => previous.savedLot != current.savedLot,
        listener: (context, state) {
          final saved = state.savedLot;
          if (saved != null) context.pop<Lot>(saved);
        },
        child: const _LotEditorView(),
      ),
    );
  }
}

class _LotEditorView extends StatelessWidget {
  const _LotEditorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(FieldStrings.newLotTitle)),
      body: SafeArea(
        child: BlocBuilder<LotEditorBloc, LotEditorState>(
          builder: (context, state) {
            final bloc = context.read<LotEditorBloc>();
            if (state.step == LotEditorStep.details) {
              return _LotDetailsStep(state: state, bloc: bloc);
            }
            final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
            return Column(
              children: [
                Expanded(
                  flex: keyboardVisible ? 1 : 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: GeographicLotEditor(
                      state: state,
                      existingLots: state.existingLots,
                      onVertexAdded: (point) => bloc.add(
                        LotEditorEvent.vertexAdded(point),
                      ),
                      onVertexSelected: (index) => bloc.add(
                        LotEditorEvent.vertexSelected(index),
                      ),
                      onVertexMoveStarted: (index) => bloc.add(
                        LotEditorEvent.vertexMoveStarted(index),
                      ),
                      onVertexMoved: (index, point) => bloc.add(
                        LotEditorEvent.vertexMoved(index, point),
                      ),
                    ),
                  ),
                ),
                Offstage(
                  offstage: keyboardVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: LotEditorToolbar(
                      canUndo: state.canUndo,
                      canRedo: state.canRedo,
                      canDelete: state.selectedVertexIndex != null,
                      canClear: state.vertices.isNotEmpty,
                      onUndo: () => bloc.add(
                        const LotEditorEvent.undoRequested(),
                      ),
                      onRedo: () => bloc.add(
                        const LotEditorEvent.redoRequested(),
                      ),
                      onDelete: () => bloc.add(
                        const LotEditorEvent.selectedVertexDeleted(),
                      ),
                      onClear: () async {
                        final shouldClear = await _confirmClear(context);
                        if (shouldClear && context.mounted) {
                          bloc.add(const LotEditorEvent.clearRequested());
                        }
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: keyboardVisible ? 4 : 2,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            top: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LotDraftSummary(
                                state: state,
                                onNameChanged: (name) => bloc.add(
                                  LotEditorEvent.nameChanged(name),
                                ),
                                onSurfaceChanged: (value) => bloc.add(
                                  LotEditorEvent.surfaceChanged(value),
                                ),
                              ),
                              if (state.showValidationErrors && state.validation.issues.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                LotValidationMessage(
                                  issue: state.validation.issues.first,
                                ),
                              ],
                              if (state.errorMessage case final message?) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  message,
                                  style: AppTypography.errorBody,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              AppFilledButton(
                                label: state.isClosed
                                    ? FieldStrings.continueLotDetailsCta
                                    : FieldStrings.closeLotBoundaryCta,
                                icon: Icon(
                                  state.isClosed ? Icons.check : Icons.polyline_outlined,
                                ),
                                onPressed: state.isClosed
                                    ? state.canContinue
                                          ? () => bloc.add(
                                              const LotEditorEvent.detailsStepRequested(),
                                            )
                                          : null
                                    : state.vertices.length >= 3
                                    ? () => bloc.add(
                                        const LotEditorEvent.boundaryCloseRequested(),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmClear(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(FieldStrings.clearBoundaryDialogTitle),
            content: const Text(FieldStrings.clearBoundaryDialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(FieldStrings.cancelClearBoundaryCta),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(FieldStrings.confirmClearBoundaryCta),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _LotDetailsStep extends StatelessWidget {
  const _LotDetailsStep({required this.state, required this.bloc});

  final LotEditorState state;
  final LotEditorBloc bloc;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Text(FieldStrings.lotDetailsStepTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.md),
        AppInfoCell(
          label: FieldStrings.lotNameLabel,
          value: state.draft.name.trim(),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInfoCell(
          label: FieldStrings.surfaceHectaresLabel,
          value: '${(state.draft.surfaceTenths / 10).toStringAsFixed(1)} ${FieldStrings.hectaresSuffix}',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDropdownFormField<String>(
          title: FieldStrings.forageResourceFieldLabel,
          hintText: FieldStrings.forageResourceHint,
          initialValue: state.draft.forageResourceCode,
          options: [
            for (final resource in InitialForageResources.values)
              AppDropdownOption(value: resource.code, label: resource.displayName),
          ],
          onChanged: (value) => bloc.add(
            LotEditorEvent.forageResourceChanged(value),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppChoiceSelector<bool>(
          title: FieldStrings.waterAvailabilityLabel,
          value: state.draft.hasWater,
          options: const [
            AppChoiceOption(value: true, label: FieldStrings.waterAvailable),
            AppChoiceOption(value: false, label: FieldStrings.waterUnavailable),
          ],
          onChanged: (value) => bloc.add(
            LotEditorEvent.waterAvailabilityChanged(hasWater: value),
          ),
        ),
        if (state.draft.hasWater == null) ...[
          const SizedBox(height: AppSpacing.xs),
          const Text(FieldStrings.requiredWaterError, style: AppTypography.formFieldHelper),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppDropdownFormField<LotStatus>(
          title: FieldStrings.lotStatusLabel,
          hintText: FieldStrings.lotStatusLabel,
          initialValue: state.draft.status,
          options: [
            for (final status in LotStatus.values)
              if (status != LotStatus.unknown)
                AppDropdownOption(
                  value: status,
                  label: FieldStrings.statusName(status),
                ),
          ],
          onChanged: (value) {
            if (value != null) bloc.add(LotEditorEvent.statusChanged(value));
          },
        ),
        if (state.errorMessage case final message?) ...[
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.errorBody),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppFilledButton(
          label: state.isSaving ? FieldStrings.savingLotCta : FieldStrings.saveLotCta,
          icon: const Icon(Icons.save_outlined),
          onPressed: state.canComplete ? () => bloc.add(const LotEditorEvent.saveRequested()) : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppOutlinedButton(
          label: FieldStrings.backToBoundaryCta,
          onPressed: () => bloc.add(const LotEditorEvent.boundaryStepRequested()),
        ),
      ],
    );
  }
}
