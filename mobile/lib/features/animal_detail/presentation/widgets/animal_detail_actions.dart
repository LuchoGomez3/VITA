import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Acciones de la ficha preparadas visualmente, todavía sin operaciones reales.
class AnimalDetailActions extends StatelessWidget {
  /// Usa el sexo para ofrecer la edición de preñez solo a hembras.
  const AnimalDetailActions({required this.sex, super.key});

  /// Sexo registrado; no se infiere ni se modifica el estado reproductivo.
  final AnimalSex sex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: buttonWidth,
              child: const AppOutlinedButton(
                label: AnimalDetailStrings.enterWeightAction,
                icon: Icon(Icons.monitor_weight_outlined),
                onPressed: _previewOnly,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: const AppOutlinedButton(
                label: AnimalDetailStrings.changeCategoryAction,
                icon: Icon(Icons.category_outlined),
                onPressed: _previewOnly,
              ),
            ),
            if (sex == AnimalSex.female)
              SizedBox(
                width: buttonWidth,
                child: const AppOutlinedButton(
                  label: AnimalDetailStrings.changePregnancyAction,
                  icon: Icon(Icons.edit_outlined),
                  onPressed: _previewOnly,
                ),
              ),
            SizedBox(
              width: buttonWidth,
              child: AppOutlinedButton(
                label: AnimalDetailStrings.deathAction,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                textStyle: AppTypography.smallEmphasis.copyWith(color: AppColors.error),
                onPressed: () => _previewDeath(context),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ensaya confirmación y deshacer sin alterar el animal ni crear eventos.
  Future<void> _previewDeath(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeathConfirmationDialog(),
    );
    if (confirmed != true || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(AnimalDetailStrings.deathPreviewMessage),
          duration: Duration(seconds: 8),
          action: SnackBarAction(
            label: AnimalDetailStrings.undoAction,
            onPressed: _previewOnly,
          ),
        ),
      );
  }
}

/// Entrada visual para observaciones; no abre formularios ni guarda texto aún.
class AnimalObservationEntryButton extends StatelessWidget {
  /// Crea el acceso con lápiz que se integrará con la edición de observaciones.
  const AnimalObservationEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _previewOnly,
      icon: const Icon(Icons.edit_outlined),
      label: const Text(AnimalDetailStrings.newObservationAction),
    );
  }
}

/// Confirmación visual: aclara que esta rama no registra bajas todavía.
class _DeathConfirmationDialog extends StatelessWidget {
  const _DeathConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
      title: const Text(AnimalDetailStrings.deathConfirmationTitle),
      content: const Text(AnimalDetailStrings.deathConfirmationMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AnimalDetailStrings.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text(AnimalDetailStrings.confirmAction),
        ),
      ],
    );
  }
}

/// Mantiene los botones sin cambios de datos, navegación ni estado de negocio.
void _previewOnly() {
  // TODO(equipo): Conectar casos de uso al integrar la rama de edición.
}
