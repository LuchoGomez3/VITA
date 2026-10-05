import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:go_router/go_router.dart';

/// Formularios disponibles desde los accesos de la ficha.
enum AnimalDetailAction {
  /// Nueva pesada manual.
  weight,

  /// Asignación de categoría compatible.
  category,

  /// Condición reproductiva de una hembra.
  reproduction,

  /// Confirmación de baja por muerte.
  death,

  /// Nueva entrada en el historial de notas.
  observation,
}

/// Recoge una intención validada; el Cubit decide cuándo y cómo guardarla.
Future<AnimalDetailChange?> showAnimalDetailChangeDialog(
  BuildContext context,
  AnimalDetail detail,
  AnimalDetailAction action,
) {
  return showDialog<AnimalDetailChange>(
    context: context,
    builder: (context) => switch (action) {
      AnimalDetailAction.weight => const _TextEntryDialog(isWeight: true),
      AnimalDetailAction.observation => const _TextEntryDialog(isWeight: false),
      AnimalDetailAction.category => _CategoryDialog(detail: detail),
      AnimalDetailAction.reproduction => _ReproductionDialog(detail: detail),
      AnimalDetailAction.death => const _DeathDialog(),
    },
  );
}

/// El formulario es dueño del controlador de texto y lo libera al cerrar.
class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog({required this.isWeight});
  final bool isWeight;

  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width * 0.9;
    return AlertDialog(
      constraints: BoxConstraints(minWidth: dialogWidth, maxWidth: dialogWidth),
      title: Text(widget.isWeight ? AnimalDetailStrings.enterWeightAction : AnimalDetailStrings.newObservationAction),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: AppTextFormField(
            controller: _controller,
            title: widget.isWeight ? AnimalDetailStrings.weightInputLabel : AnimalDetailStrings.observationInputLabel,
            keyboardType: widget.isWeight
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.multiline,
            maxLines: widget.isWeight ? 1 : 4,
            validator: (value) {
              if (!widget.isWeight) {
                return value == null || value.trim().isEmpty ? AnimalDetailStrings.emptyObservationError : null;
              }
              final weight = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
              return weight == null || !weight.isFinite || weight <= 0 ? AnimalDetailStrings.invalidWeightError : null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text(AnimalDetailStrings.cancelAction)),
        FilledButton(onPressed: _submit, child: const Text(AnimalDetailStrings.saveAction)),
      ],
    );
  }

  /// Normaliza la coma decimal; una nota conserva el texto escrito por el usuario.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now().toUtc();
    final change = widget.isWeight
        ? AnimalDetailChange.weight(weightKg: double.parse(_controller.text.trim().replaceAll(',', '.')), date: now)
        : AnimalDetailChange.observation(text: _controller.text, date: now);
    context.pop(change);
  }
}

/// Filtra sexo y condición vigente para no ofrecer un cambio que rechazará backend.
class _CategoryDialog extends StatelessWidget {
  const _CategoryDialog({required this.detail});
  final AnimalDetail detail;

  @override
  Widget build(BuildContext context) {
    final knownReproduction =
        detail.reproductiveStatus == AnimalReproductiveStatus.pregnant ||
        detail.reproductiveStatus == AnimalReproductiveStatus.empty;
    final options = detail.categories.where(
      (category) =>
          (category.allowedSex == null || category.allowedSex == detail.sex) &&
          (!knownReproduction || category.allowsReproductiveStatus),
    );
    return SimpleDialog(
      title: const Text(AnimalDetailStrings.changeCategoryAction),
      children: [
        if (options.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(AnimalDetailStrings.noCompatibleCategories),
          ),
        for (final category in options)
          SimpleDialogOption(
            onPressed: () => context.pop(AnimalDetailChange.category(categoryId: category.id)),
            child: Row(
              children: [
                Expanded(child: Text(category.name)),
                if (category.id == detail.categoryId) const Icon(Icons.check),
              ],
            ),
          ),
        SimpleDialogOption(onPressed: () => context.pop(), child: const Text(AnimalDetailStrings.cancelAction)),
      ],
    );
  }
}

/// Ofrece preñada y vacía únicamente cuando la categoría las admite.
class _ReproductionDialog extends StatelessWidget {
  const _ReproductionDialog({required this.detail});
  final AnimalDetail detail;

  @override
  Widget build(BuildContext context) {
    final category = detail.categories.where((option) => option.id == detail.categoryId).firstOrNull;
    final options = [
      AnimalReproductiveStatus.undetermined,
      if (category?.allowsReproductiveStatus ?? false) ...[
        AnimalReproductiveStatus.empty,
        AnimalReproductiveStatus.pregnant,
      ],
    ];
    return SimpleDialog(
      title: const Text(AnimalDetailStrings.changePregnancyAction),
      children: [
        if (category?.allowsReproductiveStatus != true)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(AnimalDetailStrings.reproductiveCategoryHelp),
          ),
        for (final status in options)
          SimpleDialogOption(
            onPressed: () => context.pop(AnimalDetailChange.reproduction(status: status)),
            child: Text(AnimalDetailStrings.reproductionLabel(status)),
          ),
        SimpleDialogOption(
          onPressed: () => context.pop(const AnimalDetailChange.reproduction(status: null)),
          child: const Text(AnimalDetailStrings.notApplicable),
        ),
        SimpleDialogOption(onPressed: () => context.pop(), child: const Text(AnimalDetailStrings.cancelAction)),
      ],
    );
  }
}

/// La muerte requiere confirmación y no elimina el historial del animal.
class _DeathDialog extends StatelessWidget {
  const _DeathDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.warning_amber_rounded),
    title: const Text(AnimalDetailStrings.deathConfirmationTitle),
    content: const Text(AnimalDetailStrings.deathConfirmationMessage),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text(AnimalDetailStrings.cancelAction)),
      TextButton(
        onPressed: () => context.pop(const AnimalDetailChange.death()),
        child: const Text(AnimalDetailStrings.confirmAction),
      ),
    ],
  );
}
