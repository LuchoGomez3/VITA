import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Titulo centrado y reutilizable del app bar del wizard de establecimiento.
class EstablishmentRegisterAppBarTitle extends StatelessWidget {
  /// Crea el encabezado con el titulo del flujo y el paso actual.
  const EstablishmentRegisterAppBarTitle({
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
          EstablishmentRegisterStrings.pageTitle,
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
