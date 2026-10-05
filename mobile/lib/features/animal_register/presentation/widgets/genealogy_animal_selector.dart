import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Animal disponible para vincular como madre o padre.
class GenealogyAnimalOption {
  /// Crea una opcion de animal para el selector de genealogia.
  const GenealogyAnimalOption({
    required this.id,
    required this.visualTag,
    required this.breed,
    required this.rfid,
  });

  /// UUID real del animal.
  final String id;

  /// Numero visual de la caravana.
  final String visualTag;

  /// Raza visible del animal.
  final String breed;

  /// RFID del animal.
  final String rfid;
}

/// Selector reutilizable de un animal dentro de la genealogia.
class GenealogyAnimalSelector extends StatelessWidget {
  /// Crea un selector con busqueda, valor seleccionado y resultados.
  const GenealogyAnimalSelector({
    required this.title,
    required this.searchHint,
    required this.options,
    required this.onSelected,
    super.key,
    this.selectedAnimal,
    this.onClear,
    this.onSearchChanged,
    this.validationMessage,
    this.enabled = true,
  });

  /// Titulo del vinculo genealogico.
  final String title;

  /// Hint del campo de busqueda.
  final String searchHint;

  /// Resultados disponibles para seleccionar.
  final List<GenealogyAnimalOption> options;

  /// Animal seleccionado actualmente.
  final GenealogyAnimalOption? selectedAnimal;

  /// Callback que informa el animal seleccionado.
  final ValueChanged<GenealogyAnimalOption> onSelected;

  /// Callback para quitar el animal seleccionado.
  final VoidCallback? onClear;

  /// Callback que informa cambios en el texto de busqueda.
  final ValueChanged<String>? onSearchChanged;

  /// Mensaje de búsqueda sin resultados.
  final String? validationMessage;

  /// Solo permite buscar luego de seleccionar un establecimiento.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.secondaryEmphasis),
        const SizedBox(height: AppSpacing.xs),
        if (selectedAnimal != null)
          _SelectedGenealogyAnimal(
            animal: selectedAnimal!,
            onClear: onClear,
          )
        else ...[
          AppTextFormField(
            hintText: searchHint,
            enabled: enabled,
            validation: validationMessage == null ? AppFieldValidation.neutral : AppFieldValidation.invalid,
            validationMessage: validationMessage,
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            onChanged: onSearchChanged,
          ),
          if (options.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _GenealogyResults(
              options: options,
              onSelected: onSelected,
            ),
          ],
        ],
      ],
    );
  }
}

class _SelectedGenealogyAnimal extends StatelessWidget {
  const _SelectedGenealogyAnimal({
    required this.animal,
    this.onClear,
  });

  final GenealogyAnimalOption animal;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          _EarTagPreview(visualTag: animal.visualTag),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${animal.visualTag} · ${animal.breed}',
                  style: AppTypography.secondaryEmphasis.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(animal.rfid, style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Quitar selección',
            onPressed: onClear,
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenealogyResults extends StatelessWidget {
  const _GenealogyResults({
    required this.options,
    required this.onSelected,
  });

  final List<GenealogyAnimalOption> options;
  final ValueChanged<GenealogyAnimalOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < options.length; index++) ...[
            _GenealogyResultTile(
              animal: options[index],
              onTap: () => onSelected(options[index]),
            ),
            if (index < options.length - 1) const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _GenealogyResultTile extends StatelessWidget {
  const _GenealogyResultTile({
    required this.animal,
    required this.onTap,
  });

  final GenealogyAnimalOption animal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            _EarTagPreview(visualTag: animal.visualTag),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${animal.visualTag} · ${animal.breed} · ${animal.rfid}',
                style: AppTypography.secondaryEmphasis.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarTagPreview extends StatelessWidget {
  const _EarTagPreview({
    required this.visualTag,
  });

  final String visualTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        visualTag.replaceFirst(' ', '\n'),
        style: AppTypography.smallEmphasis.copyWith(
          color: AppColors.textPrimary,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
