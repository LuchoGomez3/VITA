import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_edit_dialogs.dart';
import 'package:go_router/go_router.dart';

/// Accesos que recogen una edición y la entregan al Cubit de la ficha.
class AnimalDetailActions extends StatelessWidget {
  /// Recibe la ficha vigente para filtrar los cambios válidos del animal.
  const AnimalDetailActions({required this.animalDetail, super.key});

  /// Datos de negocio usados por los formularios, sin infraestructura de persistencia.
  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    final canEdit =
        animalDetail.status == AnimalStatus.active &&
        context.read<AnimalDetailCubit>().state.saving is! Loading<AnimalDetail>;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionButton(
              width: width,
              label: AnimalDetailStrings.enterWeightAction,
              icon: Icons.monitor_weight_outlined,
              onPressed: canEdit ? () => _edit(context, AnimalDetailAction.weight) : null,
            ),
            _ActionButton(
              width: width,
              label: AnimalDetailStrings.changeCategoryAction,
              icon: Icons.category_outlined,
              onPressed: canEdit ? () => _edit(context, AnimalDetailAction.category) : null,
            ),
            if (animalDetail.sex == AnimalSex.female)
              _ActionButton(
                width: width,
                label: AnimalDetailStrings.changePregnancyAction,
                icon: Icons.edit_outlined,
                onPressed: canEdit ? () => _edit(context, AnimalDetailAction.reproduction) : null,
              ),
            SizedBox(
              width: constraints.maxWidth,
              child: Row(
                children: [
                  _ActionButton(
                    width: width,
                    label: AnimalDetailStrings.deathAction,
                    icon: Icons.remove_circle_outline,
                    isDestructive: true,
                    onPressed: canEdit ? () => _edit(context, AnimalDetailAction.death) : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionButton(
                    width: width,
                    label: AnimalDetailStrings.changeLotAction,
                    icon: Icons.swap_horiz,
                    onPressed: canEdit ? () => _changeLot(context) : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// La ruta es dueña de la operación; al volver se lee la ubicación guardada.
  Future<void> _changeLot(BuildContext context) async {
    await context.push<void>(
      AppRoutes.lotMovementFor(establishmentId: animalDetail.establishmentId, animalId: animalDetail.id),
    );
    if (context.mounted) await context.read<AnimalDetailCubit>().loadAnimalData(animalDetail.id);
  }

  Future<void> _edit(BuildContext context, AnimalDetailAction action) async {
    final change = await showAnimalDetailChangeDialog(context, animalDetail, action);
    if (change == null || !context.mounted) return;
    await context.read<AnimalDetailCubit>().save(change);
  }
}

/// Mantiene el mismo tamaño y estilo para acciones productivas y la baja.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.width,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
  final double width;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: AppOutlinedButton(
      label: label,
      icon: Icon(icon, color: isDestructive ? AppColors.error : null),
      onPressed: onPressed,
      textStyle: isDestructive ? AppTypography.smallEmphasis.copyWith(color: AppColors.error) : null,
    ),
  );
}

/// Agrega una nota independiente, sin sustituir las observaciones existentes.
class AnimalObservationEntryButton extends StatelessWidget {
  /// Recibe la ficha para asociar la entrada al animal que se está visualizando.
  const AnimalObservationEntryButton({required this.animalDetail, super.key});

  /// Animal que recibirá la nota al confirmar el formulario.
  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    final saving = context.read<AnimalDetailCubit>().state.saving is Loading<AnimalDetail>;
    return TextButton.icon(
      onPressed: saving ? null : () => _addObservation(context),
      icon: const Icon(Icons.edit_outlined),
      label: const Text(AnimalDetailStrings.newObservationAction),
    );
  }

  Future<void> _addObservation(BuildContext context) async {
    final change = await showAnimalDetailChangeDialog(context, animalDetail, AnimalDetailAction.observation);
    if (change == null || !context.mounted) return;
    await context.read<AnimalDetailCubit>().save(change);
  }
}
