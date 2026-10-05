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

/// Pantalla principal para la gestion y consulta de la hacienda.
class LivestockPage extends StatelessWidget {
  /// Crea la pantalla de accesos ganaderos.
  const LivestockPage({required this.createAccessCubit, super.key});

  /// Construye la consulta offline de establecimientos autorizados.
  final LivestockAccessCubitFactory createAccessCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createAccessCubit()..load(),
      child: const _LivestockView(),
    );
  }
}

class _LivestockView extends StatelessWidget {
  const _LivestockView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: LivestockStrings.title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LivestockStrings.animalRegisterTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(LivestockStrings.animalRegisterDescription),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: LivestockStrings.animalRegisterButton,
                      onPressed: () => context.push(AppRoutes.animalRegisterStep1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _SaleRegistrationAccess(),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LivestockStrings.animalDetailTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(LivestockStrings.animalDetailDescription),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: LivestockStrings.animalDetailButton,
                      onPressed: () => context.go(
                        AppRoutes.animalDetailById(
                          '550e8400-e29b-41d4-a716-446655440059',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LivestockStrings.fieldTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(LivestockStrings.fieldDescription),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: LivestockStrings.fieldButton,
                      onPressed: () => context.push(AppRoutes.field),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resuelve permisos y establecimiento antes de abrir el flujo comercial.
class _SaleRegistrationAccess extends StatelessWidget {
  const _SaleRegistrationAccess();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivestockAccessCubit, ResultState<List<EstablishmentMembership>>>(
      builder: (context, state) => switch (state) {
        Data<List<EstablishmentMembership>>(:final data) when data.isNotEmpty => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _SaleRegistrationCard(establishments: data),
        ),
        ResultError<List<EstablishmentMembership>>() => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _SaleAccessErrorCard(),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _SaleRegistrationCard extends StatelessWidget {
  const _SaleRegistrationCard({required this.establishments});

  final List<EstablishmentMembership> establishments;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LivestockStrings.saleRegisterTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(LivestockStrings.saleRegisterDescription),
          const SizedBox(height: AppSpacing.md),
          AppFilledButton(
            key: const Key('livestockSaleRegisterButton'),
            label: LivestockStrings.saleRegisterButton,
            onPressed: () => _openSaleRegistration(context),
          ),
        ],
      ),
    );
  }

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
  Widget build(BuildContext context) {
    return AppSurfaceCard(
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
}
