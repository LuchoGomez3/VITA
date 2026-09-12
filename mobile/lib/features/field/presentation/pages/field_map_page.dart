import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_overview_cubit.dart';
import 'package:frontend_mayoral/features/field/presentation/navigation/lot_editor_route_data.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_paddock_card.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_view_toggle.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';
import 'package:go_router/go_router.dart';

/// Fábrica inyectable del visor local de lotes.
typedef LotOverviewCubitFactory = LotOverviewCubit Function();

/// Vista de los lotes persistidos en el dispositivo.
class FieldMapPage extends StatelessWidget {
  /// Crea la pantalla con su composición offline.
  const FieldMapPage({required this.createCubit, super.key});

  /// Construye el estado dueño del catálogo y la colección SQLite.
  final LotOverviewCubitFactory createCubit;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createCubit()..load(),
    child: const _FieldMapView(),
  );
}

class _FieldMapView extends StatelessWidget {
  const _FieldMapView();

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
          // TODO(field-map): reemplazar el fondo esquemático por un proveedor
          // real sólo cuando se definan permisos, tiles, caché y conversión de
          // geometrías; este lienzo seguirá siendo el fallback offline.
          Expanded(
            child: state.view == LotOverviewView.schematic
                ? LotOverviewCanvas(
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
