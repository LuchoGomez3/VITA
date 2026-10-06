import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:go_router/go_router.dart';

/// Crea el cubit cuyo ciclo de vida pertenece a la pestaña Hacienda.
typedef LivestockAccessCubitFactory = LivestockAccessCubit Function();

/// Organiza la lectura de caravanas y los accesos de gestión de hacienda.
class LivestockPage extends StatelessWidget {
  /// Crea la pantalla y consulta los establecimientos habilitados para vender.
  const LivestockPage({
    required this.createAccessCubit,
    required this.onIdentifyAnimal,
    super.key,
  });

  /// Construye la consulta offline de establecimientos autorizados.
  final LivestockAccessCubitFactory createAccessCubit;

  /// Resuelve el establecimiento antes de abrir el lector compartido.
  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createAccessCubit()..load(),
    child: _LivestockView(onIdentifyAnimal: onIdentifyAnimal),
  );
}

class _LivestockView extends StatelessWidget {
  const _LivestockView({required this.onIdentifyAnimal});

  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AppHeader(title: LivestockStrings.title),
    body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        // Desplaza el espacio seguro con el contenido para conservar la
        // separación final respecto de la barra de navegación.
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReadingCard(onPressed: onIdentifyAnimal),
            const SizedBox(height: AppSpacing.sm),
            const _SaleRegistrationAccess(),
            _ManagementCard(
              title: LivestockStrings.fieldTitle,
              description: LivestockStrings.fieldDescription,
              icon: Icons.map_outlined,
              onTap: () => context.push(AppRoutes.field),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ManagementCard(
              title: LivestockStrings.healthEventsTitle,
              description: LivestockStrings.healthEventsDescription,
              icon: Icons.medical_services_outlined,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    color: AppColors.backgroundSecondaryLight,
    elevation: 3,
    shadowColor: AppColors.cardShadow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: AppSpacing.xl,
          backgroundColor: AppColors.surface,
          child: Icon(
            Icons.bluetooth_searching,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          LivestockStrings.readTagTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(LivestockStrings.readTagDescription),
        const SizedBox(height: AppSpacing.lg),
        AppFilledButton(
          label: LivestockStrings.readTagTitle,
          icon: const Icon(Icons.bluetooth),
          onPressed: onPressed,
        ),
      ],
    ),
  );
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.description,
    required this.icon,
    this.interactionKey,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Key? interactionKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: EdgeInsets.zero,
    elevation: 3,
    shadowColor: AppColors.cardShadow,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: interactionKey,
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
                  Text(
                    onTap == null ? LivestockStrings.comingSoon : description,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Visibility(
              visible: onTap != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Resuelve permisos y establecimiento antes de abrir el flujo comercial.
class _SaleRegistrationAccess extends StatelessWidget {
  const _SaleRegistrationAccess();

  @override
  Widget build(BuildContext context) => BlocBuilder<LivestockAccessCubit, ResultState<List<EstablishmentMembership>>>(
    builder: (context, state) => switch (state) {
      Data<List<EstablishmentMembership>>(:final data) when data.isNotEmpty => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _SaleRegistrationCard(establishments: data),
      ),
      ResultError<List<EstablishmentMembership>>() => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: _SaleAccessErrorCard(),
      ),
      _ => const SizedBox.shrink(),
    },
  );
}

class _SaleRegistrationCard extends StatelessWidget {
  const _SaleRegistrationCard({required this.establishments});

  final List<EstablishmentMembership> establishments;

  @override
  Widget build(BuildContext context) => _ManagementCard(
    title: LivestockStrings.saleRegisterTitle,
    description: LivestockStrings.saleRegisterDescription,
    icon: Icons.attach_money,
    interactionKey: const Key('livestockSaleRegisterButton'),
    onTap: () => _openSaleRegistration(context),
  );

  Future<void> _openSaleRegistration(BuildContext context) async {
    final establishmentId = establishments.length == 1
        ? establishments.single.id
        : await showDialog<String>(
            context: context,
            builder: (dialogContext) => SimpleDialog(
              title: const Text(
                LivestockStrings.saleEstablishmentSelectionTitle,
              ),
              children: [
                for (final establishment in establishments)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(
                      dialogContext,
                    ).pop(establishment.id),
                    child: Text(establishment.name),
                  ),
              ],
            ),
          );
    if (establishmentId == null || !context.mounted) return;
    await context.push(
      AppRoutes.livestockSaleForEstablishment(establishmentId),
    );
  }
}

class _SaleAccessErrorCard extends StatelessWidget {
  const _SaleAccessErrorCard();

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(LivestockStrings.saleAccessError),
        const SizedBox(height: AppSpacing.md),
        AppOutlinedButton(
          label: LivestockStrings.retry,
          onPressed: context.read<LivestockAccessCubit>().load,
        ),
      ],
    ),
  );
}
