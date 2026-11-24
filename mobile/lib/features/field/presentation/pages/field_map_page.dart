import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_overview_cubit.dart';
import 'package:frontend_mayoral/features/field/presentation/navigation/lot_editor_route_data.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_paddock_card.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_view_toggle.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Fábrica inyectable del visor local de lotes.
typedef LotOverviewCubitFactory = LotOverviewCubit Function();

/// Vista de los lotes persistidos en el dispositivo.
class FieldMapPage extends StatelessWidget {
  /// Crea la pantalla con su composición offline.
  const FieldMapPage({required this.createCubit, this.createPhotoActions, super.key});

  /// Construye el estado dueño del catálogo y la colección SQLite.
  final LotOverviewCubitFactory createCubit;

  /// Fuente de la foto privada del establecimiento.
  final FieldMapPhotoActions Function()? createPhotoActions;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createCubit()..load(),
    child: _FieldMapView(photoActions: createPhotoActions?.call()),
  );
}

class _FieldMapView extends StatelessWidget {
  const _FieldMapView({this.photoActions});

  final FieldMapPhotoActions? photoActions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LotOverviewCubit, LotOverviewState>(
      builder: (context, state) {
        final selectedId = state.selectedEstablishmentId;
        final establishmentName = selectedId == null
            ? FieldStrings.noEstablishmentTitle
            : state.establishments[selectedId] ?? selectedId;
        return Scaffold(
          appBar: AppHeader(
            title: FieldStrings.title,
            headline: establishmentName,
          ),
          body: SafeArea(child: _body(context, state)),
          floatingActionButton: selectedId == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _createLot(context, state),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text(FieldStrings.newLotCta),
                ),
        );
      },
    );
  }

  Widget _body(BuildContext context, LotOverviewState state) {
    if (state.loadState is Loading<void> || state.loadState is Initial<void>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadState is Data<void> && state.selectedEstablishmentId == null) {
      return const Center(child: Text(FieldStrings.noEstablishmentMessage));
    }
    if (state.loadState case ResultError<void>(:final error)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.message),
              const SizedBox(height: AppSpacing.md),
              AppFilledButton(
                label: FieldStrings.retryCta,
                onPressed: context.read<LotOverviewCubit>().load,
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          if (state.establishments.length > 1) ...[
            AppDropdownFormField<String>(
              initialValue: state.selectedEstablishmentId,
              title: FieldStrings.establishmentSelectorLabel,
              hintText: FieldStrings.establishmentSelectorLabel,
              options: [
                for (final entry in state.establishments.entries)
                  AppDropdownOption(value: entry.key, label: entry.value),
              ],
              onChanged: (value) {
                if (value != null) context.read<LotOverviewCubit>().selectEstablishment(value);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              AppStatusChip(
                label: FieldStrings.localLotCount(state.lots.length),
                tone: AppStatusChipTone.success,
                showDot: true,
              ),
              const SizedBox(width: AppSpacing.xs),
              AppStatusChip(
                label: FieldStrings.totalHectaresChip(
                  state.totalHectares.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: state.view == LotOverviewView.schematic
                ? _FieldMapWithPhoto(
                    key: ValueKey(state.selectedEstablishmentId),
                    establishmentId: state.selectedEstablishmentId!,
                    actions: photoActions,
                    lots: state.lots,
                    onLotSelected: (lotId) => _openLotDetail(context, lotId),
                  )
                : _LotList(
                    lots: state.lots,
                    animalCounts: state.animalCounts,
                    onLotSelected: (lotId) => _openLotDetail(context, lotId),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FieldViewToggle(
              isMapActive: state.view == LotOverviewView.schematic,
              onMapSelected: () => context.read<LotOverviewCubit>().showView(
                LotOverviewView.schematic,
              ),
              onListSelected: () => context.read<LotOverviewCubit>().showView(
                LotOverviewView.list,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createLot(BuildContext context, LotOverviewState state) async {
    final establishmentId = state.selectedEstablishmentId;
    if (establishmentId == null) return;
    final saved = await context.push<Lot>(
      AppRoutes.lotRegister,
      extra: LotEditorRouteData(
        establishmentId: establishmentId,
        existingLots: state.lots,
      ),
    );
    if (saved == null || !context.mounted) return;
    await context.read<LotOverviewCubit>().refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(FieldStrings.lotSavedMessage(saved.name))),
    );
  }

  Future<void> _openLotDetail(BuildContext context, String lotId) async {
    await context.push<bool>(AppRoutes.fieldDetailById(lotId));
    if (!context.mounted) return;
    await context.read<LotOverviewCubit>().refresh();
  }
}

class _FieldMapWithPhoto extends StatefulWidget {
  const _FieldMapWithPhoto({
    required this.establishmentId,
    required this.actions,
    required this.lots,
    required this.onLotSelected,
    super.key,
  });

  final String establishmentId;
  final FieldMapPhotoActions? actions;
  final List<Lot> lots;
  final ValueChanged<String> onLotSelected;

  @override
  State<_FieldMapWithPhoto> createState() => _FieldMapWithPhotoState();
}

class _FieldMapWithPhotoState extends State<_FieldMapWithPhoto> {
  late Future<Uint8List?>? _photo = widget.actions?.read(widget.establishmentId);
  bool _selecting = false;

  Future<void> _select() async {
    setState(() => _selecting = true);
    try {
      final bytes = await widget.actions?.select(widget.establishmentId);
      if (mounted && bytes != null) setState(() => _photo = Future.value(bytes));
    } on Exception catch (error, stackTrace) {
      Logger('FieldMapPhoto').warning('No se pudo guardar el fondo local.', error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(FieldStrings.mapPhotoError)));
      }
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _photo,
    builder: (context, snapshot) => LotOverviewCanvas(
      lots: widget.lots,
      onLotSelected: widget.onLotSelected,
      photo: snapshot.data,
      onSelectPhoto: widget.actions == null || _selecting ? null : _select,
    ),
  );
}

class _LotList extends StatelessWidget {
  const _LotList({
    required this.lots,
    required this.animalCounts,
    required this.onLotSelected,
  });

  final List<Lot> lots;
  final Map<String, int> animalCounts;
  final ValueChanged<String> onLotSelected;

  @override
  Widget build(BuildContext context) {
    if (lots.isEmpty) {
      return const Center(child: Text(FieldStrings.noLocalLotsMessage));
    }
    return ListView.separated(
      itemCount: lots.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final lot = lots[index];
        return FieldPaddockCard(
          lot: lot,
          animalCount: animalCounts[lot.id] ?? 0,
          onTap: () => onLotSelected(lot.id),
        );
      },
    );
  }
}
