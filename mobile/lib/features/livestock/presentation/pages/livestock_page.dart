import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/animal_list_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_reader_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:frontend_mayoral/features/livestock/presentation/widgets/animal_list_tile.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por el router para construir el cubit de la lista.
typedef AnimalListCubitFactory = AnimalListCubit Function();

/// Factory del Cubit que prepara la lectura RFID.
typedef LivestockReaderCubitFactory = LivestockReaderCubit Function();

/// Factory del Cubit que resuelve los establecimientos habilitados para venta.
typedef LivestockAccessCubitFactory = LivestockAccessCubit Function();

/// Abre el lector para un establecimiento autorizado.
typedef IdentifyAnimal = Future<void> Function(String establishmentId);

/// Abre el registro de venta para un establecimiento autorizado.
typedef RegisterLivestockSale = Future<void> Function(String establishmentId);

/// Hacienda: lista de animales (diseño "Lista de animales").
///
/// Lee los animales guardados en el celular, así funciona sin conexión. Tocar
/// un animal abre su ficha; "Nuevo animal" abre el alta. Arriba a la derecha
/// quedan los accesos que antes eran tarjetas: leer una caravana y el mapa de
/// "Campo y potreros".
class LivestockPage extends StatelessWidget {
  /// Crea la pantalla de Hacienda.
  const LivestockPage({
    required this.createCubit,
    required this.createReaderCubit,
    required this.createAccessCubit,
    required this.onIdentifyAnimal,
    required this.onRegisterSale,
    super.key,
  });

  /// Crea el cubit con sus dependencias ya resueltas.
  final AnimalListCubitFactory createCubit;

  /// Crea el cubit que resuelve en qué campo leer la caravana.
  final LivestockReaderCubitFactory createReaderCubit;

  /// Crea el Cubit que aplica los permisos financieros offline.
  final LivestockAccessCubitFactory createAccessCubit;

  /// Navega al lector dentro del establecimiento elegido.
  final IdentifyAnimal onIdentifyAnimal;

  /// Navega al registro de venta dentro del establecimiento elegido.
  final RegisterLivestockSale onRegisterSale;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => createCubit()..load()),
        BlocProvider(create: (_) => createReaderCubit()),
        BlocProvider(create: (_) => createAccessCubit()..load()),
      ],
      child: _LivestockView(
        onIdentifyAnimal: onIdentifyAnimal,
        onRegisterSale: onRegisterSale,
      ),
    );
  }
}

class _LivestockView extends StatelessWidget {
  const _LivestockView({
    required this.onIdentifyAnimal,
    required this.onRegisterSale,
  });

  final IdentifyAnimal onIdentifyAnimal;
  final RegisterLivestockSale onRegisterSale;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LivestockReaderCubit, ResultState<List<LivestockEstablishment>>>(
          listener: (context, state) {
            if (state is ResultError<List<LivestockEstablishment>>) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(LivestockStrings.establishmentsError),
                ),
              );
            }
          },
        ),
        BlocListener<LivestockAccessCubit, ResultState<List<LivestockEstablishment>>>(
          listener: (context, state) {
            if (state is ResultError<List<LivestockEstablishment>>) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(LivestockStrings.saleAccessError)),
              );
            }
          },
        ),
      ],
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: LivestockStrings.animalListTitle,
        titleWidget: _HeaderTitle(
          onIdentifyAnimal: onIdentifyAnimal,
          onRegisterSale: onRegisterSale,
        ),
      ),
      body: const Column(
        children: [
          _Filters(),
          Expanded(child: _AnimalList()),
        ],
      ),
      // La barra de navegación del shell se dibuja encima del cuerpo
      // (extendBody); su alto llega como padding inferior del MediaQuery.
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: FloatingActionButton(
          // El shell ya tiene su botón flotante (cámara); dos con el mismo
          // heroTag rompen la animación de navegación.
          heroTag: 'livestock-new-animal',
          tooltip: LivestockStrings.newAnimalButton,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () => _openAndReload(context, AppRoutes.animalRegisterStep1),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Abre [location] y, al volver, recarga la lista (puede haber un alta nueva).
Future<void> _openAndReload(BuildContext context, String location) async {
  final cubit = context.read<AnimalListCubit>();
  await context.push(location);
  await cubit.load();
}

class _Filters extends StatelessWidget {
  const _Filters();

  static final _pillBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(999),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AnimalListCubit>();
    final total = context.select((AnimalListCubit c) => c.state.allAnimals.length);
    final categories = context.select((AnimalListCubit c) => c.state.categories);
    final selected = context.select((AnimalListCubit c) => c.state.category);

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            style: AppTypography.formFieldValue,
            decoration: InputDecoration(
              isDense: true,
              hintText: LivestockStrings.searchHint,
              hintStyle: AppTypography.formFieldHint,
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              // El tema de los formularios dibuja un borde; en el diseño el
              // buscador es una píldora sin borde.
              border: _pillBorder,
              enabledBorder: _pillBorder,
              focusedBorder: _pillBorder,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: LivestockStrings.allAnimalsChip(total),
                  isSelected: selected == null,
                  onTap: () => cubit.selectCategory(null),
                ),
                for (final category in categories)
                  _CategoryChip(
                    label: category,
                    isSelected: selected == category,
                    onTap: () => cubit.selectCategory(category),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        avatar: isSelected ? const Icon(Icons.circle, size: 8, color: AppColors.primary) : null,
        labelStyle: AppTypography.smallEmphasis.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        selectedColor: AppColors.backgroundSecondary,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: isSelected ? AppColors.borderPositiveContainer : AppColors.border),
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _AnimalList extends StatelessWidget {
  const _AnimalList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnimalListCubit>().state;

    return switch (state.animals) {
      ResultError<List<AnimalListEntry>>(:final error) => _Message(text: error.message),
      Data<List<AnimalListEntry>>(:final data) when data.isEmpty => const _Message(
        title: LivestockStrings.emptyTitle,
        text: LivestockStrings.emptyDescription,
      ),
      Data<List<AnimalListEntry>>() when state.visibleAnimals.isEmpty => const _Message(
        text: LivestockStrings.noResults,
      ),
      Data<List<AnimalListEntry>>() => RefreshIndicator(
        onRefresh: context.read<AnimalListCubit>().load,
        child: ListView.separated(
          // Deja lugar para que el botón flotante no tape la última fila.
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          itemCount: state.visibleAnimals.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final animal = state.visibleAnimals[index];
            return AnimalListTile(
              animal: animal,
              onTap: () => _openAndReload(context, AppRoutes.animalDetailById(animal.id)),
            );
          },
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.title});

  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final heading = title;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (heading != null) ...[
              Text(heading, style: AppTypography.pageTitle, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(text, style: AppTypography.pageBodyTitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Cabecera del diseño: selector de establecimiento a la izquierda y el título.
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.onIdentifyAnimal,
    required this.onRegisterSale,
  });

  final IdentifyAnimal onIdentifyAnimal;
  final RegisterLivestockSale onRegisterSale;

  @override
  Widget build(BuildContext context) {
    final establishments = context.select((AnimalListCubit c) => c.state.establishments);
    final selectedId = context.select((AnimalListCubit c) => c.state.establishmentId);

    // El título va centrado en la pantalla, no en el espacio que deja el
    // selector: por eso se superponen en vez de ir en una fila.
    return Stack(
      alignment: Alignment.center,
      children: [
        const Padding(
          // Margen para que el selector y los accesos no tapen el título.
          padding: EdgeInsets.only(left: 96, right: 144),
          child: Text(
            LivestockStrings.animalListTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.appBarTitle,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AppEstablishmentPicker(
            establishments: establishments,
            selectedId: selectedId,
            allLabel: LivestockStrings.allEstablishments,
            onSelected: context.read<AnimalListCubit>().selectEstablishment,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _HeaderActions(
            onIdentifyAnimal: onIdentifyAnimal,
            onRegisterSale: onRegisterSale,
          ),
        ),
      ],
    );
  }
}

/// Accesos comerciales, lectura de caravanas y mapa que antes eran tarjetas
/// de Hacienda.
class _HeaderActions extends StatefulWidget {
  const _HeaderActions({
    required this.onIdentifyAnimal,
    required this.onRegisterSale,
  });

  final IdentifyAnimal onIdentifyAnimal;
  final RegisterLivestockSale onRegisterSale;

  @override
  State<_HeaderActions> createState() => _HeaderActionsState();
}

class _HeaderActionsState extends State<_HeaderActions> {
  /// Evita abrir dos lectores con toques repetidos (#74).
  bool _isOpeningReader = false;

  /// Evita que toques repetidos abran dos selectores o flujos de venta.
  bool _isOpeningSale = false;

  @override
  Widget build(BuildContext context) {
    final saleAccess = context.watch<LivestockAccessCubit>().state;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (saleAccess case Data<List<LivestockEstablishment>>(:final data) when data.isNotEmpty)
          IconButton(
            tooltip: LivestockStrings.saleRegisterTitle,
            onPressed: _isOpeningSale ? null : () => _openSale(data),
            icon: const Icon(Icons.attach_money),
          ),
        IconButton(
          tooltip: LivestockStrings.readTagTitle,
          onPressed: _isOpeningReader ? null : _openReader,
          icon: const Icon(Icons.contactless_outlined),
        ),
        IconButton(
          tooltip: LivestockStrings.fieldTitle,
          onPressed: () => context.push(AppRoutes.field),
          icon: const Icon(Icons.map_outlined),
        ),
      ],
    );
  }

  /// Usa el establecimiento seleccionado si tiene permiso; si no, solicita
  /// uno entre los que el catalogo local habilita para operaciones financieras.
  Future<void> _openSale(List<LivestockEstablishment> establishments) async {
    if (_isOpeningSale) return;
    setState(() => _isOpeningSale = true);
    try {
      final selectedId = context.read<AnimalListCubit>().state.establishmentId;
      final selectedIsAllowed = establishments.any(
        (establishment) => establishment.id == selectedId,
      );
      final establishmentId = selectedIsAllowed
          ? selectedId
          : establishments.length == 1
          ? establishments.single.id
          : await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              useSafeArea: true,
              builder: (context) => _SaleEstablishmentPicker(
                establishments: establishments,
              ),
            );
      if (mounted && establishmentId != null) {
        // `context.push` completa recien cuando se cierra la ruta. No se debe
        // mantener el acceso deshabilitado durante toda esa espera porque el
        // shell puede volver a mostrar Hacienda antes de completar el Future.
        final navigation = widget.onRegisterSale(establishmentId);
        if (mounted) setState(() => _isOpeningSale = false);
        await navigation;
      }
    } finally {
      if (mounted) setState(() => _isOpeningSale = false);
    }
  }

  /// Con un campo elegido en el selector lee ahí; si no, pregunta en cuál.
  Future<void> _openReader() async {
    if (_isOpeningReader) return;
    final selectedId = context.read<AnimalListCubit>().state.establishmentId;
    if (selectedId != null) {
      await widget.onIdentifyAnimal(selectedId);
      return;
    }

    setState(() => _isOpeningReader = true);
    try {
      final cubit = context.read<LivestockReaderCubit>();
      await cubit.load();
      if (!mounted) return;
      if (cubit.state case Data<List<LivestockEstablishment>>(:final data)) {
        await _handleEstablishments(data);
      }
    } finally {
      if (mounted) setState(() => _isOpeningReader = false);
    }
  }

  Future<void> _handleEstablishments(List<LivestockEstablishment> establishments) async {
    if (establishments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(LivestockStrings.noEstablishments)),
      );
      return;
    }

    final establishmentId = establishments.length == 1
        ? establishments.single.id
        : await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            useSafeArea: true,
            builder: (context) => _ReaderEstablishmentPicker(establishments: establishments),
          );
    if (mounted && establishmentId != null) {
      await widget.onIdentifyAnimal(establishmentId);
    }
  }
}

class _SaleEstablishmentPicker extends StatelessWidget {
  const _SaleEstablishmentPicker({required this.establishments});

  final List<LivestockEstablishment> establishments;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              LivestockStrings.saleEstablishmentSelectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final establishment in establishments)
            ListTile(
              leading: const Icon(Icons.agriculture_outlined),
              title: Text(establishment.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(establishment.id),
            ),
        ],
      ),
    );
  }
}

class _ReaderEstablishmentPicker extends StatelessWidget {
  const _ReaderEstablishmentPicker({required this.establishments});

  final List<LivestockEstablishment> establishments;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              LivestockStrings.selectEstablishment,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final establishment in establishments)
            ListTile(
              leading: const Icon(Icons.agriculture_outlined),
              title: Text(establishment.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(establishment.id),
            ),
        ],
      ),
    );
  }
}
