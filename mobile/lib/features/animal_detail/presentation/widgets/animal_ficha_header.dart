import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_formatters.dart';

/// Título de la ficha (diseño `FichaHeader`): caravana, raza y "categoría · edad".
class AnimalFichaTitle extends StatelessWidget {
  /// Crea el título para [animal].
  const AnimalFichaTitle({required this.animal, super.key});

  /// Animal de la ficha.
  final AnimalDetail animal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppEarTagBadge(visualTag: animal.visualTag),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                animal.breed,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mediumEmphasis.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                AnimalDetailStrings.headerSubtitle(animal.categoryName, animal.birthDate.ageLabel()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.formFieldHelper.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón redondo de la cabecera de la ficha (volver).
class AnimalFichaRoundButton extends StatelessWidget {
  /// Crea el botón con [icon].
  const AnimalFichaRoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  /// Ícono del botón.
  final IconData icon;

  /// Texto accesible.
  final String tooltip;

  /// Acción al tocar.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          fixedSize: const Size(36, 36),
          minimumSize: const Size(36, 36),
        ),
        icon: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
