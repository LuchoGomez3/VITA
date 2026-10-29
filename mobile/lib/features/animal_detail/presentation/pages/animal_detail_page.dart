import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_ficha_header.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_genealogy_tab.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_general_tab.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_weighings_tab.dart';
import 'package:frontend_mayoral/features/weighing/presentation/mock/weighing_mock.dart';
import 'package:frontend_mayoral/features/weighing/presentation/pages/weighing_page.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Factory usada por composition root/router para construir el Cubit.
typedef AnimalDetailCubitFactory = AnimalDetailCubit Function();

/// Ficha del animal (diseño "Ficha · General" y sus pestañas).
///
/// Cabecera con la caravana, la raza y "categoría · edad", y debajo el menú
/// General · Genealogía · Pesajes · Sanidad · Movimientos.
class AnimalDetailPage extends StatelessWidget {
  /// Crea la ficha para [animalId].
  const AnimalDetailPage({
    required this.animalId,
    required this.createCubit,
    required this.createGenealogyCubit,
    super.key,
  });

  /// Identificador usado para cargar el animal.
  final String animalId;

  /// Crea el Cubit con dependencias resueltas fuera de presentation.
  final AnimalDetailCubitFactory createCubit;

  /// Crea el Cubit que carga padres, abuelos y crías.
  final AnimalGenealogyCubitFactory createGenealogyCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..loadAnimalData(animalId),
      child: _AnimalDetailView(createGenealogyCubit: createGenealogyCubit),
    );
  }
}

/// Pestañas de la ficha, en el orden del diseño.
enum AnimalFichaTab {
  /// Identificación, observaciones y sincronización.
  general(AnimalDetailStrings.generalTab),

  /// Árbol genealógico y crías.
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
  const _AnimalDetailView({required this.createGenealogyCubit});

  final AnimalGenealogyCubitFactory createGenealogyCubit;

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
    final animal = switch (state.detail) {
      Data<AnimalDetail>(:final data) => data,
      _ => null,
    };
    final isWeighingsTab = AnimalFichaTab.values[_tabs.index] == AnimalFichaTab.weighings;

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
      body: switch (state.detail) {
        Data<AnimalDetail>(:final data) => TabBarView(
          controller: _tabs,
          children: [
            AnimalGeneralTab(
              animal: data,
              photo: switch (state.photo) {
                Data<AnimalPhoto?>(:final data) => data,
                _ => null,
              },
              onRetrySync: () => context.read<AnimalDetailCubit>().retrySync(data.id),
            ),
            AnimalGenealogyTab(animal: data, createCubit: widget.createGenealogyCubit),
            AnimalWeighingsTab(animal: data),
            const AnimalFichaComingSoon(
              icon: Icons.vaccines_outlined,
              title: AnimalDetailStrings.comingSoonTitle,
              message: AnimalDetailStrings.healthComingSoon,
            ),
            _MovementsPlaceholder(animal: data),
          ],
        ),
        ResultError<AnimalDetail>(:final error) => Center(child: Text(error.message)),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: animal != null && isWeighingsTab
          ? FloatingActionButton(
              heroTag: 'animal-ficha-new-weighing',
              tooltip: AnimalDetailStrings.newWeighingTooltip,
              shape: const CircleBorder(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              onPressed: () => _chooseWeighingMethod(context, animal),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.livestock);
  }

  /// Ofrece las tres formas de pesar que ya existen: balanza Bluetooth, carga
  /// manual y foto (Pesaje IA).
  Future<void> _chooseWeighingMethod(BuildContext context, AnimalDetail animal) async {
    final method = await showModalBottomSheet<_WeighingMethod>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
              child: Text(AnimalDetailStrings.weighingMethodSheetTitle, style: AppTypography.pageTitle),
            ),
            for (final method in _WeighingMethod.values)
              ListTile(
                leading: Icon(method.icon, color: AppColors.primary),
                title: Text(method.label, style: AppTypography.mediumEmphasis),
                onTap: () => Navigator.of(sheetContext).pop(method),
              ),
          ],
        ),
      ),
    );
    if (method == null || !context.mounted) {
      return;
    }

    switch (method) {
      case _WeighingMethod.bluetooth || _WeighingMethod.manual:
        final cubit = context.read<AnimalDetailCubit>();
        final saved = await context.push<bool>(
          AppRoutes.weighing,
          extra: WeighingRequest(
            animalId: animal.id,
            establishmentId: animal.establishmentId,
            animal: WeighingAnimalMock(
              visualTag: animal.visualTag,
              rfid: animal.rfidTagNumber,
              breedAndCategory: [animal.breed, animal.categoryName].where((part) => part.isNotEmpty).join(' · '),
              weightKg: animal.currentWeight.round(),
            ),
            initialTab: method == _WeighingMethod.bluetooth ? WeighingCaptureTab.bluetooth : WeighingCaptureTab.manual,
          ),
        );
        // Un pesaje nuevo cambia el gráfico, el histórico y el último peso.
        if (saved ?? false) {
          await cubit.loadAnimalData(animal.id);
        }
      case _WeighingMethod.photo:
        await _openCamera(context);
    }
  }

  /// Igual que el botón "Pesaje IA" de la barra: por ahora solo abre la
  /// cámara (la estimación del peso está en desarrollo).
  Future<void> _openCamera(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ImagePicker().pickImage(source: ImageSource.camera, requestFullMetadata: false);
    } on PlatformException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(AnimalDetailStrings.cameraError)));
    }
  }
}

enum _WeighingMethod {
  bluetooth(AnimalDetailStrings.weighingWithBluetooth, Icons.bluetooth),
  manual(AnimalDetailStrings.weighingManual, Icons.dialpad),
  photo(AnimalDetailStrings.weighingWithPhoto, Icons.photo_camera_outlined);

  const _WeighingMethod(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Movimientos: por ahora muestra el potrero actual. El historial y el cambio
/// de potrero se agregan en el próximo paso.
class _MovementsPlaceholder extends StatelessWidget {
  const _MovementsPlaceholder({required this.animal});

  final AnimalDetail animal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const AnimalFichaSectionTitle(AnimalDetailStrings.currentLotLabel),
        const SizedBox(height: AppSpacing.xs),
        AnimalFichaDataGroup(
          rows: [
            AnimalFichaDataRow(
              label: AnimalDetailStrings.currentLotLabel,
              value: animal.lotName.isEmpty ? AnimalDetailStrings.noLot : animal.lotName,
            ),
          ],
        ),
      ],
    );
  }
}
