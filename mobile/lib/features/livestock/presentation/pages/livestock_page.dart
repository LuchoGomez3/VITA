import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_reader_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:go_router/go_router.dart';

/// Factory que crea el Cubit responsable de preparar la lectura RFID.
typedef LivestockReaderCubitFactory = LivestockReaderCubit Function();

/// Abre el lector para un establecimiento autorizado.
typedef IdentifyAnimal = Future<void> Function(String establishmentId);

/// Organiza la lectura de caravanas y la consulta territorial de la hacienda.
class LivestockPage extends StatelessWidget {
  /// Crea la pantalla con el flujo de identificación inyectado.
  const LivestockPage({
    required this.createCubit,
    required this.onIdentifyAnimal,
    super.key,
  });

  /// Crea el estado local perteneciente a esta pantalla.
  final LivestockReaderCubitFactory createCubit;

  /// Navega al lector dentro del establecimiento seleccionado.
  final IdentifyAnimal onIdentifyAnimal;

  @override
  Widget build(BuildContext context) => BlocProvider<LivestockReaderCubit>(
    create: (_) => createCubit(),
    child: _LivestockView(onIdentifyAnimal: onIdentifyAnimal),
  );
}

class _LivestockView extends StatefulWidget {
  const _LivestockView({required this.onIdentifyAnimal});

  final IdentifyAnimal onIdentifyAnimal;

  @override
  State<_LivestockView> createState() => _LivestockViewState();
}

class _LivestockViewState extends State<_LivestockView> {
  bool _isOpeningReader = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LivestockReaderCubit, ResultState<List<LivestockEstablishment>>>(
      listener: (context, state) {
        switch (state) {
          case ResultError<List<LivestockEstablishment>>():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(LivestockStrings.establishmentsError)),
            );
          case Initial<List<LivestockEstablishment>>() ||
              Loading<List<LivestockEstablishment>>() ||
              Data<List<LivestockEstablishment>>():
            break;
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: LivestockStrings.title),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          // Iguala los márgenes de Inicio y desplaza el espacio seguro con
          // el contenido para conservar la separación final con la barra.
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadingCard(
                isLoading: _isOpeningReader,
                onPressed: _openReader,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ManagementCard(
                title: LivestockStrings.fieldTitle,
                description: LivestockStrings.fieldDescription,
                icon: Icons.map_outlined,
                onTap: () => context.push(AppRoutes.field),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReader() async {
    if (_isOpeningReader) return;

    setState(() => _isOpeningReader = true);
    try {
      final cubit = context.read<LivestockReaderCubit>();
      await cubit.load();
      if (!mounted) return;

      switch (cubit.state) {
        case Data<List<LivestockEstablishment>>(:final data):
          await _handleEstablishments(context, data);
        case Initial<List<LivestockEstablishment>>() ||
            Loading<List<LivestockEstablishment>>() ||
            ResultError<List<LivestockEstablishment>>():
          break;
      }
    } finally {
      if (mounted) setState(() => _isOpeningReader = false);
    }
  }

  Future<void> _handleEstablishments(
    BuildContext context,
    List<LivestockEstablishment> establishments,
  ) async {
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
            builder: (context) => _ReaderEstablishmentPicker(
              establishments: establishments,
            ),
          );
    if (context.mounted && establishmentId != null) {
      await widget.onIdentifyAnimal(establishmentId);
    }
  }
}

/// Destaca la identificación como punto de entrada al trabajo con animales.
class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      color: AppColors.backgroundSecondaryLight,
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: AppSpacing.xl,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.bluetooth_searching, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(LivestockStrings.readTagTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          const Text(LivestockStrings.readTagDescription),
          const SizedBox(height: AppSpacing.lg),
          AppFilledButton(
            label: LivestockStrings.readTagTitle,
            loadingLabel: LivestockStrings.loadingEstablishments,
            isLoading: isLoading,
            icon: const Icon(Icons.bluetooth),
            onPressed: onPressed,
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

/// Presenta un acceso secundario disponible dentro de Hacienda.
class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  /// Nombre del módulo dentro de Hacienda.
  final String title;

  /// Resumen del destino disponible.
  final String description;

  /// Identificación visual del tipo de gestión.
  final IconData icon;

  /// Abre el módulo seleccionado.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.backgroundTertiary,
                child: Icon(icon, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
