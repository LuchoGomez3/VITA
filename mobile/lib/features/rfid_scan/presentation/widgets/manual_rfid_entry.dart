import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/rfid_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';

/// Permite iniciar la misma identificacion RFID mediante ingreso manual.
class ManualRfidEntry extends StatefulWidget {
  /// Crea el formulario de ingreso manual.
  const ManualRfidEntry({
    required this.onSubmitted,
    required this.onChanged,
    required this.onSuggestionSelected,
    required this.suggestions,
    super.key,
  });

  /// Recibe el valor que debe procesar el BLoC.
  final ValueChanged<String> onSubmitted;

  /// Informa el prefijo para consultar coincidencias en SQLite.
  final ValueChanged<String> onChanged;

  /// Coincidencias locales visibles debajo del campo.
  final List<IdentifiedAnimal> suggestions;

  /// Procesa directamente la caravana elegida por el productor.
  final ValueChanged<IdentifiedAnimal> onSuggestionSelected;

  @override
  State<ManualRfidEntry> createState() => _ManualRfidEntryState();
}

class _ManualRfidEntryState extends State<ManualRfidEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.keyboard_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text(RfidScanStrings.manualEntryTitle, style: AppTypography.secondaryEmphasis),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextFormField(
            key: const Key('manualRfidInput'),
            controller: _controller,
            hintText: RfidScanStrings.manualEntryHint,
            keyboardType: TextInputType.number,
            maxCharacters: 15,
            inputFormatters: [RfidInputFormatter()],
            onChanged: widget.onChanged,
          ),
          if (widget.suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              RfidScanStrings.manualSuggestionsTitle,
              style: AppTypography.smallEmphasis,
            ),
            const SizedBox(height: AppSpacing.xs),
            _ManualRfidSuggestions(
              animals: widget.suggestions,
              onSelected: _selectSuggestion,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          AppOutlinedButton(
            label: RfidScanStrings.searchManualRfid,
            icon: const Icon(Icons.search),
            onPressed: () => widget.onSubmitted(_controller.text),
          ),
        ],
      ),
    );
  }

  void _selectSuggestion(IdentifiedAnimal animal) {
    _controller.clear();
    widget.onChanged('');
    widget.onSuggestionSelected(animal);
  }
}

class _ManualRfidSuggestions extends StatelessWidget {
  const _ManualRfidSuggestions({
    required this.animals,
    required this.onSelected,
  });

  final List<IdentifiedAnimal> animals;
  final ValueChanged<IdentifiedAnimal> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.onPrimary,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Column(
      children: [
        for (var index = 0; index < animals.length; index++) ...[
          _ManualRfidSuggestionTile(
            animal: animals[index],
            onTap: () => onSelected(animals[index]),
          ),
          if (index < animals.length - 1) const Divider(height: 1, color: AppColors.border),
        ],
      ],
    ),
  );
}

class _ManualRfidSuggestionTile extends StatelessWidget {
  const _ManualRfidSuggestionTile({required this.animal, required this.onTap});

  final IdentifiedAnimal animal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: ValueKey('manualRfidSuggestion-${animal.id}'),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          _EarTagPreview(visualTag: animal.visualTag),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              [
                animal.rfidTagNumber,
                if (animal.categoryName.trim().isNotEmpty) animal.categoryName,
                if (animal.lotName.trim().isNotEmpty) animal.lotName,
              ].join(' · '),
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

class _EarTagPreview extends StatelessWidget {
  const _EarTagPreview({required this.visualTag});

  final String visualTag;

  @override
  Widget build(BuildContext context) => Container(
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
