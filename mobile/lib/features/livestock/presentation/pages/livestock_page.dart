import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal para la gestion y consulta de la hacienda.
class LivestockPage extends StatelessWidget {
  /// Crea la pantalla de accesos ganaderos.
  const LivestockPage({super.key});

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
                        AppRoutes.animalDetailById('550e8400-e29b-41d4-a716-446655440059'),
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
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LivestockStrings.teamTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(LivestockStrings.teamDescription),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: LivestockStrings.teamButton,
                      onPressed: () => context.push(AppRoutes.team),
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
