import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/registered_animal_summary_card.dart';
import 'package:go_router/go_router.dart';

/// Pantalla final de confirmacion del alta de animal.
class RegistrarAnimalSuccessPage extends StatelessWidget {
  /// Crea la pantalla de exito del flujo de alta.
  const RegistrarAnimalSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              const _SuccessAssetPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              const Text(
                AnimalRegisterStrings.successTitle,
                style: AppTypography.successTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                AnimalRegisterStrings.successSubtitle,
                style: AppTypography.successSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              const RegisteredAnimalSummaryCard(
                visualTag: AnimalRegisterStrings.successMockVisualTag,
                title: AnimalRegisterStrings.successMockAnimalTitle,
                rfid: AnimalRegisterStrings.successMockRfid,
                destination: AnimalRegisterStrings.successMockDestination,
              ),
              const Spacer(flex: 2),
              AppFilledButton(
                label: AnimalRegisterStrings.successRegisterAnotherButton,
                icon: const Icon(Icons.add),
                onPressed: () => _startAnotherAnimal(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: AnimalRegisterStrings.successViewDetailsButton,
                icon: const Icon(Icons.visibility_outlined),
                // TODO(agus): navegar a la ficha del animal cuando exista.
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text(
                  AnimalRegisterStrings.successBackHomeButton,
                  style: AppTypography.outlinedButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startAnotherAnimal(BuildContext context) {
    GoRouter.of(context)
      ..go(AppRoutes.home)
      ..push(AppRoutes.animalRegisterStep1);
  }
}

/// Asset de exito placeholder.
///
class _SuccessAssetPlaceholder extends StatelessWidget {
  const _SuccessAssetPlaceholder();

  @override
  Widget build(BuildContext context) {
    // TODO(agusf): reemplazar por el asset final de exito.
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 4,
        ),
      ),
      child: const Icon(
        Icons.check,
        color: AppColors.primary,
        size: 64,
      ),
    );
  }
}
