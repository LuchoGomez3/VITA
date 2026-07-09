import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/registered_animal_summary_card.dart';
import 'package:go_router/go_router.dart';

/// Pantalla final de confirmacion del alta de animal.
class RegistrarAnimalSuccessPage extends StatelessWidget {
  /// Crea la pantalla de exito del flujo de alta.
  const RegistrarAnimalSuccessPage({
    required this.registeredAnimal,
    super.key,
  });

  /// Animal persisted locally through Brick.
  final RegisteredAnimal registeredAnimal;

  @override
  Widget build(BuildContext context) {
    final registration = registeredAnimal.registration;

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
              Text(
                'La caravana ${registration.visualTag} quedó guardada en este dispositivo y espera sincronización.',
                style: AppTypography.secondaryEmphasis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              RegisteredAnimalSummaryCard(
                visualTag: registration.visualTag,
                title: '${registration.breed} · ${registeredAnimal.displayCategory}',
                rfid: registration.rfidTagNumber,
                destination: registeredAnimal.displayDestination,
              ),
              const Spacer(flex: 2),
              AppFilledButton(
                label: AnimalRegisterStrings.successRegisterAnotherButton,
                icon: const Icon(Icons.add),
                onPressed: () => _startAnotherAnimal(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: 'Ver ficha de ${registration.visualTag}',
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
