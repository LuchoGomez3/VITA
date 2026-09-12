import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_filters.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_header.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_result.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_summary.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_movement_selector.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

const _movementSelectorOverlayExtent = 60.0;
const _compactHeaderScrollThreshold = 96.0;

/// Factory del estado del historial financiero.
typedef OperatingExpenseHistoryCubitFactory = OperatingExpenseHistoryCubit Function();

/// Historial offline-first de egresos del establecimiento activo.
class OperatingExpenseHistoryPage extends StatelessWidget {
  /// Crea la pantalla y asigna el ciclo de vida del cubit.
  const OperatingExpenseHistoryPage({
    required this.establishmentName,
    required this.createCubit,
    super.key,
  });

  /// Nombre visible del establecimiento activo.
  final String establishmentName;

  /// Construye el cubit con dependencias de composition.
  final OperatingExpenseHistoryCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: _OperatingExpenseHistoryView(establishmentName: establishmentName),
    );
  }
}

class _OperatingExpenseHistoryView extends StatefulWidget {
  const _OperatingExpenseHistoryView({required this.establishmentName});

  final String establishmentName;

  @override
  State<_OperatingExpenseHistoryView> createState() => _OperatingExpenseHistoryViewState();
}

class _OperatingExpenseHistoryViewState extends State<_OperatingExpenseHistoryView> {
  final _scrollController = ScrollController();
  bool _compactHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateHeaderMode);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateHeaderMode)
      ..dispose();
    super.dispose();
  }

  void _updateHeaderMode() {
    final compact = _scrollController.offset >= _compactHeaderScrollThreshold;
    if (compact != _compactHeader) setState(() => _compactHeader = compact);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperatingExpenseHistoryCubit, OperatingExpenseHistoryState>(
      listenWhen: (previous, current) => previous.message != current.message || previous.export != current.export,
      listener: _listen,
      builder: (context, state) => Scaffold(
        appBar: OperatingExpenseHistoryHeader(
          compact: _compactHeader,
          establishmentName: widget.establishmentName,
          state: state,
          onExport: () => _export(context, state),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: context.read<OperatingExpenseHistoryCubit>().refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: _movementSelectorOverlayExtent),
                    ),
                    SliverToBoxAdapter(
                      child: OperatingExpenseHistorySummary(
                        establishmentName: widget.establishmentName,
                        state: state,
                      ),
                    ),
                    if (state.refreshing)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    SliverToBoxAdapter(
                      child: OperatingExpenseHistoryFilters(state: state),
                    ),
                    OperatingExpenseHistoryResult(state: state),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: _compactHeader,
                child: AnimatedSlide(
                  offset: _compactHeader ? const Offset(0, -1) : Offset.zero,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity: _compactHeader ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: OperatingExpenseMovementSelector(
                      onIncomeSelected: () => _showMessage(
                        context,
                        OperatingExpenseStrings.incomeComingSoon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _listen(BuildContext context, OperatingExpenseHistoryState state) async {
    if (state.message case final message?) _showMessage(context, message);
    if (state.export case Data<OperatingExpenseExport>(:final data)) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(data.bytes, mimeType: data.mediaType, name: data.filename)],
          fileNameOverrides: [data.filename],
        ),
      );
      if (context.mounted) context.read<OperatingExpenseHistoryCubit>().consumeExport();
    }
    if (state.export case ResultError<OperatingExpenseExport>(:final error)) {
      if (error.code == DomainErrorCode.unauthorized && context.mounted) context.go(AppRoutes.login);
    }
  }

  void _export(BuildContext context, OperatingExpenseHistoryState state) {
    final history = switch (state.history) {
      Data<OperatingExpenseHistory>(:final data) => data,
      _ => null,
    };
    if (history?.pendingCount case final count? when count > 0) {
      _showMessage(context, OperatingExpenseStrings.exportPendingWarning);
    }
    unawaited(context.read<OperatingExpenseHistoryCubit>().exportCsv());
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
