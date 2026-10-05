import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/cubit/lot_movement_cubit.dart';
import 'package:frontend_mayoral/features/lot_movement/presentation/strings/lot_movement_strings.dart';
import 'package:go_router/go_router.dart';

/// Flujo de asignación inicial y traslado, con Cubit propiedad de esta ruta.
class LotMovementPage extends StatelessWidget {
  /// La composición inyecta el origen o animal inicial sin importar otras features.
  const LotMovementPage({required this.createCubit, super.key});

  /// Fábrica para que BlocProvider cierre las escuchas al salir de la pantalla.
  final LotMovementCubit Function() createCubit;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = createCubit();
      unawaited(
        cubit.load().then((_) {
          if (!cubit.isClosed) unawaited(cubit.load(refreshRemote: true));
        }),
      );
      return cubit;
    },
    child: const _MovementView(),
  );
}

class _MovementView extends StatelessWidget {
  const _MovementView();
  @override
  Widget build(BuildContext context) => BlocBuilder<LotMovementCubit, LotMovementState>(
    builder: (context, state) => Scaffold(
      appBar: const AppHeader(title: LotMovementStrings.title),
      body: SafeArea(
        child: switch (state.context) {
          Data<MovementContext>(:final data) => _MovementBody(state: state, data: data),
          ResultError<MovementContext>(:final error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.message),
                TextButton(
                  onPressed: () => context.read<LotMovementCubit>().load(),
                  child: const Text(LotMovementStrings.retry),
                ),
              ],
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    ),
  );
}

class _MovementBody extends StatefulWidget {
  const _MovementBody({required this.state, required this.data});
  final LotMovementState state;
  final MovementContext data;
  @override
  State<_MovementBody> createState() => _MovementBodyState();
}

class _MovementBodyState extends State<_MovementBody> {
  final _reason = TextEditingController();
  String? _destinationId;
  DateTime _date = DateTime.now();
  String? _validation;
  bool _confirming = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final data = widget.data;
    final saving = state.saving is Loading<AnimalLotMovement>;
    final destinations = data.destinations.where((lot) => lot.id != state.sourceLotId).toList();
    final animals = data.animals.where((animal) => animal.lotId == state.sourceLotId).toList();
    // El origen de la ruta puede no estar en la caché (por ejemplo, un lote
    // vacío). Conservamos esa opción para que el valor seleccionado exista
    // exactamente una vez; el string vacío queda reservado para «Sin lote».
    final originIds = <String>{
      ...data.origins.map((lot) => lot.id),
      ...data.animals.map((a) => a.lotId).whereType<String>(),
      if (state.sourceLotId case final id?) id,
    }..remove('');
    return RefreshIndicator(
      onRefresh: () => context.read<LotMovementCubit>().load(refreshRemote: true),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (state.refreshing) const LinearProgressIndicator(),
          if (data.usingCachedData)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(LotMovementStrings.cached),
            ),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDropdownFormField<String>(
                  key: ValueKey('origin:${state.sourceLotId}'),
                  title: LotMovementStrings.origin,
                  hintText: LotMovementStrings.origin,
                  initialValue: state.sourceLotId ?? '',
                  options: [
                    const AppDropdownOption(value: '', label: LotMovementStrings.withoutLot),
                    for (final id in originIds) AppDropdownOption(value: id, label: _lotName(id)),
                  ],
                  onChanged: saving || _confirming
                      ? null
                      : (id) {
                          setState(() {
                            _destinationId = null;
                            _validation = null;
                          });
                          context.read<LotMovementCubit>().selectOrigin(id == '' ? null : id);
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(LotMovementStrings.animals, style: AppTypography.secondaryEmphasis),
                if (animals.isEmpty) const Text(LotMovementStrings.noAnimals),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(animal.tag),
                      subtitle: animal.canMove ? null : const Text(LotMovementStrings.unavailableAnimal),
                      value: state.selectedIds.contains(animal.id),
                      onChanged: saving || _confirming || !animal.canMove
                          ? null
                          : (value) => context.read<LotMovementCubit>().selectAnimal(animal, selected: value ?? false),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (destinations.isEmpty)
                  const Text(LotMovementStrings.noDestinations)
                else
                  AppDropdownFormField<String>(
                    key: ValueKey('${state.sourceLotId}:$_destinationId:${destinations.map((l) => l.id).join()}'),
                    title: LotMovementStrings.destination,
                    hintText: LotMovementStrings.destination,
                    initialValue: destinations.any((lot) => lot.id == _destinationId) ? _destinationId : null,
                    options: [for (final lot in destinations) AppDropdownOption(value: lot.id, label: lot.name)],
                    onChanged: saving || _confirming ? null : (id) => setState(() => _destinationId = id),
                  ),
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  controller: _reason,
                  title: LotMovementStrings.reason,
                  enabled: !saving && !_confirming,
                ),
                OutlinedButton.icon(
                  onPressed: saving || _confirming ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('${LotMovementStrings.date}: ${DateDisplayFormatter.shortDate(_date)}'),
                ),
                OutlinedButton.icon(
                  onPressed: saving || _confirming ? null : _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text('${LotMovementStrings.time}: ${TimeOfDay.fromDateTime(_date).format(context)}'),
                ),
                if (_validation case final message?) Text(message, style: AppTypography.errorBody),
                if (state.saving case ResultError<AnimalLotMovement>(:final error))
                  Text(error.message, style: AppTypography.errorBody),
                if (state.saving is Data<AnimalLotMovement>) const Text(LotMovementStrings.pendingSaved),
                const SizedBox(height: AppSpacing.md),
                AppFilledButton(
                  label: LotMovementStrings.review,
                  onPressed: saving || _confirming || destinations.isEmpty ? null : _confirm,
                ),
                if (saving) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(LotMovementStrings.history, style: AppTypography.pageTitle),
          if (state.retrying case ResultError<void>(:final error)) Text(error.message, style: AppTypography.errorBody),
          if (data.history.isEmpty) const Text(LotMovementStrings.emptyHistory),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.history.length,
            itemBuilder: (context, index) => _HistoryEntry(
              movement: data.history[index],
              source: _lotName(data.history[index].sourceLotId),
              destination: _lotName(data.history[index].destinationLotId),
              retrying: state.retrying is Loading<void>,
            ),
          ),
        ],
      ),
    );
  }

  String _lotName(String? id) => id == null
      ? LotMovementStrings.withoutLot
      : widget.data.origins.where((lot) => lot.id == id).firstOrNull?.name ??
            widget.data.destinations.where((lot) => lot.id == id).firstOrNull?.name ??
            id;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() => _date = DateTime(selected.year, selected.month, selected.day, _date.hour, _date.minute));
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (selected == null || !mounted) return;
    setState(() => _date = DateTime(_date.year, _date.month, _date.day, selected.hour, selected.minute));
  }

  /// La confirmación no escribe datos. Sólo el caso de uso posterior realiza
  /// la transacción, revalidando el origen por si cambió durante el diálogo.
  Future<void> _confirm() async {
    final destination = _destinationId;
    if (widget.state.selectedIds.isEmpty) {
      setState(() => _validation = LotMovementStrings.emptySelection);
      return;
    }
    if (destination == null ||
        _reason.text.trim().isEmpty ||
        !widget.data.destinations.any((lot) => lot.id == destination)) {
      setState(() => _validation = LotMovementStrings.invalidForm);
      return;
    }
    setState(() {
      _confirming = true;
      _validation = null;
    });
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(LotMovementStrings.confirmationTitle),
        content: Text(
          LotMovementStrings.confirmation(
            widget.state.selectedIds.length,
            _lotName(widget.state.sourceLotId),
            _lotName(destination),
          ),
        ),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(false), child: const Text(LotMovementStrings.cancel)),
          FilledButton(onPressed: () => dialogContext.pop(true), child: const Text(LotMovementStrings.confirm)),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed ?? false) {
      await context.read<LotMovementCubit>().save(
        destinationLotId: destination,
        occurredAt: _date,
        reason: _reason.text,
      );
    }
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({
    required this.movement,
    required this.source,
    required this.destination,
    required this.retrying,
  });
  final AnimalLotMovement movement;
  final String source;
  final String destination;
  final bool retrying;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$source → $destination', style: AppTypography.secondaryEmphasis),
          Text(
            '${LotMovementStrings.animalCount(movement.animalIds.length)} · ${DateDisplayFormatter.shortDate(movement.occurredAt.toLocal())}',
          ),
          Text(movement.reason),
          Text(LotMovementStrings.status(movement.syncStatus)),
          if (movement.syncStatus == MovementSyncStatus.rejected)
            Text(LotMovementStrings.rejected(movement.syncErrorCode), style: AppTypography.errorBody),
          if (movement.syncStatus != MovementSyncStatus.synchronized &&
              !LotMovementStrings.isReleased(movement.syncErrorCode))
            TextButton(
              onPressed: retrying ? null : () => context.read<LotMovementCubit>().retry(movement.id),
              child: const Text(LotMovementStrings.retry),
            ),
        ],
      ),
    ),
  );
}
