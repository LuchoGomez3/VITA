import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/cubit/quick_read_cubit.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/strings/quick_read_strings.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/widgets/quick_read_cards.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/widgets/quick_read_tiles.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/hid_rfid_keyboard_listener.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_method_sheet.dart';
import 'package:go_router/go_router.dart';

/// Panel del lector de caravanas que abre el botón central (`LectorSheet`).
///
/// Se dibuja sobre la pestaña actual, por encima de la barra de navegación.
/// El bastón HID llega como teclado: cada lectura (dígitos + Enter) se suma a
/// la sesión. La sesión ([cubit]) vive en la barra: cerrar el panel no
/// pierde las caravanas leídas, solo "Descartar" las borra.
class QuickReadPanel extends StatelessWidget {
  /// Crea el panel sobre la sesión [cubit].
  const QuickReadPanel({required this.cubit, required this.onClose, super.key});

  /// Sesión de lectura, compartida entre aperturas del panel.
  final QuickReadCubit cubit;

  /// Cierra el panel (botón "Cerrar", atrás o tocar el fondo sin lecturas).
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: _QuickReadPanelView(onClose: onClose),
    );
  }
}

class _QuickReadPanelView extends StatefulWidget {
  const _QuickReadPanelView({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_QuickReadPanelView> createState() => _QuickReadPanelViewState();
}

class _QuickReadPanelViewState extends State<_QuickReadPanelView> {
  final _readingSource = HidRfidReadingSource();
  final _manualController = TextEditingController();
  StreamSubscription<String>? _readings;

  /// Cambia al volver de otra pantalla para que el bastón recupere el foco.
  int _listenerGeneration = 0;

  QuickReadCubit get _cubit => context.read<QuickReadCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(_readingSource.startReading());
    _readings = _readingSource.readings.listen((tag) => _cubit.addTag(tag));
  }

  @override
  void dispose() {
    unawaited(_readings?.cancel());
    unawaited(_readingSource.dispose());
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        Positioned.fill(
          // Con caravanas leídas, un toque sin querer en la manga no cierra
          // el panel (el bastón dejaría de escuchar): se cierra con "Cerrar".
          child: BlocSelector<QuickReadCubit, QuickReadState, bool>(
            selector: (state) => state.items.isEmpty,
            builder: (context, isEmpty) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isEmpty ? widget.onClose : null,
              child: const ColoredBox(color: Color(0x7319140A)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.94),
                child: Material(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  clipBehavior: Clip.antiAlias,
                  child: BlocBuilder<QuickReadCubit, QuickReadState>(
                    builder: (context, state) => HidRfidKeyboardListener(
                      key: ValueKey(_listenerGeneration),
                      isListening: !state.isManualEntry,
                      onKeyEvent: _readingSource.handleKeyEvent,
                      child: _content(state),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(QuickReadState state) {
    final items = state.items;
    final body = switch (items) {
      [] => const QuickReadWaiting(),
      [RegisteredRead(:final animal)] => _single(animal),
      [UnregisteredRead(:final rfidTagNumber)] => _singleUnregistered(state, rfidTagNumber),
      _ => _multiple(state),
    };
    final message = state.message;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
        Flexible(
          child: SingleChildScrollView(
            // El botón central sobresale de la barra: deja aire debajo.
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(state),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _MessageBanner(message: message),
                ],
                const SizedBox(height: AppSpacing.sm),
                body,
                const SizedBox(height: AppSpacing.sm),
                _manualEntry(state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(QuickReadState state) {
    final label = switch (state.items.length) {
      0 => QuickReadStrings.ready,
      1 => QuickReadStrings.oneRead,
      _ => QuickReadStrings.keepReading,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: QuickReadStatusPill(label: label)),
        const SizedBox(width: AppSpacing.xs),
        if (state.items.isNotEmpty)
          TextButton(
            onPressed: () => _discard(state),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(QuickReadStrings.discard),
          ),
      ],
    );
  }

  Widget _manualEntry(QuickReadState state) {
    if (!state.isManualEntry) {
      return TextButton.icon(
        onPressed: _cubit.toggleManualEntry,
        icon: const Icon(Icons.keyboard_outlined),
        label: Text(state.items.isEmpty ? QuickReadStrings.manualEntry : QuickReadStrings.keepReadingMore),
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _manualController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: QuickReadStrings.manualHint, isDense: true),
            onSubmitted: (_) => _addManual(),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        FilledButton(onPressed: _addManual, child: const Text(QuickReadStrings.add)),
        IconButton(
          tooltip: QuickReadStrings.cancel,
          onPressed: _cubit.toggleManualEntry,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _single(QuickReadAnimal animal) {
    final weight = animal.lastWeightKg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuickReadAnimalCard(animal: animal),
        const SizedBox(height: AppSpacing.md),
        const Text(QuickReadStrings.whatToDo, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        QuickActionGrid(
          children: [
            QuickActionTile(
              icon: Icons.monitor_weight_outlined,
              label: QuickReadStrings.registerWeight,
              subtitle: weight == null
                  ? QuickReadStrings.noWeight
                  : QuickReadStrings.lastWeight(formatQuickReadWeight(weight)),
              onTap: () => _weigh(animal),
            ),
            const QuickActionTile(
              icon: Icons.vaccines_outlined,
              label: QuickReadStrings.registerTreatment,
              subtitle: QuickReadStrings.comingSoon,
            ),
            QuickActionTile(
              icon: Icons.swap_horiz,
              label: QuickReadStrings.moveLot,
              subtitle: QuickReadStrings.currentLot(animal.animal.lotName),
              onTap: () => _move([animal.animal.id]),
            ),
            QuickActionTile(
              icon: Icons.description_outlined,
              label: QuickReadStrings.goToRecord,
              subtitle: QuickReadStrings.fullHistory,
              onTap: () => _openRecord(animal.animal.id),
            ),
          ],
        ),
      ],
    );
  }

  Widget _singleUnregistered(QuickReadState state, String rfidTagNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuickReadUnregisteredCard(rfidTagNumber: rfidTagNumber, establishmentName: state.establishmentName),
        const SizedBox(height: AppSpacing.md),
        QuickActionTile(
          icon: Icons.add,
          label: QuickReadStrings.registerAnimal,
          subtitle: QuickReadStrings.tagFillsItself,
          isWide: true,
          onTap: () => _registerNew([rfidTagNumber]),
        ),
        const SizedBox(height: AppSpacing.xs),
        const QuickActionGrid(
          children: [
            QuickActionTile(
              icon: Icons.monitor_weight_outlined,
              label: QuickReadStrings.registerWeight,
              subtitle: QuickReadStrings.noWeight,
            ),
            QuickActionTile(
              icon: Icons.vaccines_outlined,
              label: QuickReadStrings.registerTreatment,
              subtitle: QuickReadStrings.comingSoon,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          QuickReadStrings.afterRegistering,
          textAlign: TextAlign.center,
          style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }

  Widget _multiple(QuickReadState state) {
    final registered = state.registeredItems;
    final unregistered = state.unregisteredItems;
    final visible = state.isListExpanded ? state.items : state.items.take(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(QuickReadStrings.readTags, style: AppTypography.mediumEmphasis),
        Row(
          children: [
            Text(
              '${state.items.length}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  if (registered.isNotEmpty)
                    _CountChip(label: QuickReadStrings.registered(registered.length), color: AppColors.primary),
                  if (unregistered.isNotEmpty)
                    _CountChip(label: QuickReadStrings.unregistered(unregistered.length), color: AppColors.warning),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // Material (no DecoratedBox) para que las filas muestren el toque.
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              children: [
                for (final item in visible)
                  QuickReadItemRow(
                    item: item,
                    onRemove: state.isListExpanded ? () => _cubit.remove(item) : null,
                    onOpen: item is RegisteredRead ? () => _openRecord(item.animal.animal.id) : null,
                  ),
                TextButton(
                  onPressed: _cubit.toggleList,
                  child: Text(
                    state.isListExpanded
                        ? QuickReadStrings.hideList
                        : '${QuickReadStrings.moreTags(state.items.length - 1)} · ${QuickReadStrings.seeList}',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (registered.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(QuickReadStrings.applyTo(registered.length), style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          QuickActionGrid(
            children: [
              const QuickActionTile(
                icon: Icons.vaccines_outlined,
                label: QuickReadStrings.registerTreatment,
                subtitle: QuickReadStrings.comingSoon,
              ),
              QuickActionTile(
                icon: Icons.swap_horiz,
                label: QuickReadStrings.moveLot,
                subtitle: QuickReadStrings.allTogether(registered.length),
                onTap: () => _move([for (final item in registered) item.animal.animal.id]),
              ),
            ],
          ),
        ],
        if (unregistered.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          QuickActionTile(
            icon: Icons.add,
            label: QuickReadStrings.registerNewAnimals(unregistered.length),
            subtitle: QuickReadStrings.registerUnregisteredTags,
            isWide: true,
            onTap: () => _registerNew([for (final item in unregistered) item.rfidTagNumber]),
          ),
        ],
      ],
    );
  }

  void _addManual() {
    final text = _manualController.text;
    unawaited(
      _cubit.addTag(text).then((added) {
        if (added) {
          _manualController.clear();
        }
      }),
    );
  }

  Future<void> _discard(QuickReadState state) async {
    if (state.items.length > 1) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(QuickReadStrings.discardQuestion),
          content: const Text(QuickReadStrings.discardBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(QuickReadStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text(QuickReadStrings.discard),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }
    _cubit.discard();
  }

  Future<void> _openRecord(String animalId) async {
    await context.push<void>(AppRoutes.animalDetailById(animalId));
    await _afterAction();
  }

  Future<void> _weigh(QuickReadAnimal animal) async {
    await startWeighing(context, (
      animalId: animal.animal.id,
      establishmentId: animal.animal.establishmentId,
      visualTag: animal.animal.visualTag,
      rfidTagNumber: animal.animal.rfidTagNumber,
      breedAndCategory: breedAndCategory(animal),
      currentWeightKg: animal.lastWeightKg?.round() ?? 0,
    ));
    await _afterAction();
  }

  Future<void> _move(List<String> animalIds) async {
    final messenger = ScaffoldMessenger.of(context);
    final summary = await context.push<GroupMovementSummary>(AppRoutes.groupMovement, extra: animalIds);
    await _afterAction();
    if (summary == null || !mounted) {
      return;
    }
    final destination = _cubit.state.registeredItems
        .where((item) => item.animal.animal.id == animalIds.first)
        .map((item) => item.animal.animal.lotName)
        .firstOrNull;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${AnimalMovementStrings.moved(summary.movedCount, destination ?? '')} ${AnimalMovementStrings.savedOffline}',
          ),
        ),
      );
  }

  /// Da de alta [rfids] de a uno; cortar un alta corta la serie.
  Future<void> _registerNew(List<String> rfids) async {
    final establishmentId = _cubit.state.establishmentId ?? await _chooseEstablishment();
    if (establishmentId == null || !mounted) {
      return;
    }
    _cubit.selectEstablishment(establishmentId);
    for (final rfid in rfids) {
      final animalId = await context.push<String>(
        AppRoutes.animalRegisterWithRfid(rfidTagNumber: rfid, establishmentId: establishmentId, fromReader: true),
      );
      await _afterAction();
      if (animalId == null || !mounted) {
        return;
      }
    }
  }

  Future<String?> _chooseEstablishment() {
    final establishments = _cubit.state.establishments;
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
              child: Text(QuickReadStrings.chooseEstablishment, style: AppTypography.pageTitle),
            ),
            for (final establishment in establishments)
              ListTile(
                title: Text(establishment.name, style: AppTypography.mediumEmphasis),
                onTap: () => Navigator.of(sheetContext).pop(establishment.id),
              ),
          ],
        ),
      ),
    );
  }

  /// Relee la sesión y le devuelve el foco al bastón.
  Future<void> _afterAction() async {
    if (!mounted) {
      return;
    }
    await _cubit.refresh();
    if (mounted) {
      setState(() => _listenerGeneration++);
    }
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: color.withValues(alpha: 0.12), shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: AppSpacing.xxs),
        child: Text(label, style: AppTypography.smallEmphasis.copyWith(color: color)),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message, style: AppTypography.smallEmphasis.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
