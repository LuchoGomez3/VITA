import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
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
            return Column(
              children: [
                Expanded(
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
                Padding(
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
                DecoratedBox(
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
                        ),
                        if (state.showValidationErrors && state.validation.issues.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          LotValidationMessage(
                            issue: state.validation.issues.first,
                          ),
                        ],
                        if (state.errorMessage case final message?) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(message, style: AppTypography.errorBody),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        AppFilledButton(
                          label: state.isSaving
                              ? FieldStrings.savingLotCta
                              : state.isClosed
                              ? FieldStrings.confirmLotBoundaryCta
                              : FieldStrings.closeLotBoundaryCta,
                          icon: Icon(
                            state.isClosed ? Icons.check : Icons.polyline_outlined,
                          ),
                          onPressed: state.isClosed
                              ? state.canComplete
                                    ? () => bloc.add(const LotEditorEvent.saveRequested())
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
