import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

/// Titulo centrado y reutilizable del app bar del flujo de alta de animal.
class RegisterAnimalAppBarTitle extends StatelessWidget {
  /// Crea el encabezado con el titulo del flujo y el paso actual.
  const RegisterAnimalAppBarTitle({
    required this.stepSubtitle,
    super.key,
  });

  /// Texto que identifica el numero y nombre del paso actual.
  final String stepSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AnimalRegisterStrings.pageTitle,
          style: AppTypography.appBarTitle,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          stepSubtitle,
          style: AppTypography.secondaryEmphasis,
        ),
      ],
    );
  }
}
