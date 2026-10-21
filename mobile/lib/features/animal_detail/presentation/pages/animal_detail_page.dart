import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_ficha_header.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_general_tab.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_weighings_tab.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/widgets/animal_movements_tab.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_method_sheet.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por composition root/router para construir el Cubit.
typedef AnimalDetailCubitFactory = AnimalDetailCubit Function();

/// Factory del cubit del historial de potreros (pestaña Movim.).
typedef MovementHistoryCubitFactory = MovementHistoryCubit Function();

/// Ficha del animal (diseño "Ficha · General" y sus pestañas).
///
/// Cabecera con la caravana, la raza y "categoría · edad", y debajo el menú
/// General · Genealogía · Pesajes · Sanidad · Movimientos.
class AnimalDetailPage extends StatelessWidget {
  /// Crea la ficha para [animalId].
  const AnimalDetailPage({
    required this.animalId,
    required this.createCubit,
    required this.createMovementHistoryCubit,
    super.key,
  });

  /// Identificador usado para cargar el animal.
  final String animalId;

  /// Crea el Cubit con dependencias resueltas fuera de presentation.
  final AnimalDetailCubitFactory createCubit;

  /// Crea el cubit del historial de potreros.
  final MovementHistoryCubitFactory createMovementHistoryCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => createCubit()..loadAnimalData(animalId)),
        BlocProvider(create: (_) => createMovementHistoryCubit()..load(animalId)),
      ],
      child: const _AnimalDetailView(),
    );
  }
}

/// Pestañas de la ficha, en el orden del diseño.
enum AnimalFichaTab {
  /// Identificación, observaciones y sincronización.
  general(AnimalDetailStrings.generalTab),

  /// Árbol genealógico (todavía no desarrollado).
  genealogy(AnimalDetailStrings.genealogyTab),

  /// Evolución del peso e histórico.
  weighings(AnimalDetailStrings.weighingsTab),

  /// Tratamientos y vacunaciones (todavía no desarrollado).
  health(AnimalDetailStrings.healthTab),

  /// Movimientos entre potreros.
  movements(AnimalDetailStrings.movementsTab);

  const AnimalFichaTab(this.label);

  /// Texto de la pestaña.
  final String label;
}

class _AnimalDetailView extends StatefulWidget {
  const _AnimalDetailView();

  @override
  State<_AnimalDetailView> createState() => _AnimalDetailViewState();
}

class _AnimalDetailViewState extends State<_AnimalDetailView> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: AnimalFichaTab.values.length, vsync: this)
    ..addListener(() {
      // Solo hace falta redibujar para mostrar u ocultar el botón de Pesajes.
      if (!_tabs.indexIsChanging) {
        setState(() {});
      }
    });

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnimalDetailCubit>().state;
    final animal = switch (state) {
      Data<AnimalDetail>(:final data) => data,
      _ => null,
    };
    final currentTab = AnimalFichaTab.values[_tabs.index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        centerTitle: true,
        leading: AnimalFichaRoundButton(
          icon: Icons.chevron_left,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _close(context),
        ),
        title: animal == null ? null : AnimalFichaTitle(animal: animal),
        actions: const [SizedBox(width: 56)],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.border,
          labelPadding: EdgeInsets.zero,
          labelStyle: AppTypography.smallEmphasis.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [for (final tab in AnimalFichaTab.values) Tab(text: tab.label)],
        ),
      ),
      body: switch (state) {
        Data<AnimalDetail>(:final data) => TabBarView(
          controller: _tabs,
          children: [
            AnimalGeneralTab(
              animal: data,
              onRetrySync: () => context.read<AnimalDetailCubit>().retrySync(data.id),
            ),
            const AnimalFichaComingSoon(
              icon: Icons.account_tree_outlined,
              title: AnimalDetailStrings.comingSoonTitle,
              message: AnimalDetailStrings.genealogyComingSoon,
            ),
            AnimalWeighingsTab(animal: data),
            const AnimalFichaComingSoon(
              icon: Icons.vaccines_outlined,
              title: AnimalDetailStrings.comingSoonTitle,
              message: AnimalDetailStrings.healthComingSoon,
            ),
            const AnimalMovementsTab(),
          ],
        ),
        ResultError<AnimalDetail>(:final error) => Center(child: Text(error.message)),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: switch ((animal, currentTab)) {
        (final animal?, AnimalFichaTab.weighings) => FloatingActionButton(
          heroTag: 'animal-ficha-new-weighing',
          tooltip: AnimalDetailStrings.newWeighingTooltip,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () => _chooseWeighingMethod(context, animal),
          child: const Icon(Icons.add),
        ),
        (final animal?, AnimalFichaTab.movements) => FloatingActionButton(
          heroTag: 'animal-ficha-move',
          tooltip: AnimalMovementStrings.moveTooltip,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () => _moveAnimals(context, animal),
          child: const Icon(Icons.add),
        ),
        _ => null,
      },
    );
  }

  /// Abre "Mover animales" con este animal y, al volver, recarga la ficha (el
  /// potrero cambió) y el historial.
  Future<void> _moveAnimals(BuildContext context, AnimalDetail animal) async {
    final detailCubit = context.read<AnimalDetailCubit>();
    final historyCubit = context.read<MovementHistoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final summary = await context.push<GroupMovementSummary>(AppRoutes.animalGroupMovementById(animal.id));
    if (summary == null) {
      return;
    }
    await Future.wait([detailCubit.loadAnimalData(animal.id), historyCubit.load(animal.id)]);
    final destination = switch (detailCubit.state) {
      Data<AnimalDetail>(:final data) => data.lotName,
      _ => '',
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${AnimalMovementStrings.moved(summary.movedCount, destination)} ${AnimalMovementStrings.savedOffline}',
          ),
        ),
      );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.livestock);
  }

  Future<void> _chooseWeighingMethod(BuildContext context, AnimalDetail animal) async {
    final cubit = context.read<AnimalDetailCubit>();
    final saved = await startWeighing(context, (
      animalId: animal.id,
      establishmentId: animal.establishmentId,
      visualTag: animal.visualTag,
      rfidTagNumber: animal.rfidTagNumber,
      breedAndCategory: [animal.breed, animal.categoryName].where((part) => part.isNotEmpty).join(' · '),
      currentWeightKg: animal.currentWeight.round(),
    ));
    // Un pesaje nuevo cambia el gráfico, el histórico y el último peso.
    if (saved) {
      await cubit.loadAnimalData(animal.id);
    }
  }
}
