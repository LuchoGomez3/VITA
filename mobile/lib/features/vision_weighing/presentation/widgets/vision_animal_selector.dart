import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_animal_selector_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:go_router/go_router.dart';

/// Permite vincular una captura con un animal local o identificarlo con RFID.
class VisionAnimalSelector extends StatelessWidget {
  /// Mantiene la selección en la revisión aunque el lector abra otra ruta.
  const VisionAnimalSelector({
    required this.getAnimalOptions,
    required this.selectedAnimal,
    required this.onSelected,
    super.key,
  });

  /// Consulta animales y establecimientos disponibles sin conexión.
  final GetVisionAnimalOptions getAnimalOptions;

  /// Animal elegido para la captura actual.
  final VisionAnimal? selectedAnimal;

  /// Comunica la identidad elegida a la revisión.
  final ValueChanged<VisionAnimal?> onSelected;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => VisionAnimalSelectorCubit(getAnimalOptions)..load(),
    child: _VisionAnimalSelectorView(selectedAnimal: selectedAnimal, onSelected: onSelected),
  );
}

class _VisionAnimalSelectorView extends StatefulWidget {
  const _VisionAnimalSelectorView({required this.selectedAnimal, required this.onSelected});

  final VisionAnimal? selectedAnimal;
  final ValueChanged<VisionAnimal?> onSelected;

  @override
  State<_VisionAnimalSelectorView> createState() => _VisionAnimalSelectorViewState();
}

class _VisionAnimalSelectorViewState extends State<_VisionAnimalSelectorView> {
  String? _establishmentId;

  /// El lector devuelve un ID; se vuelve a consultar SQLite para evitar
  /// asociar una captura con una ficha que cambió mientras estaba abierto.
  Future<void> _scan(String establishmentId) async {
    final animalId = await context.push<String>(AppRoutes.rfidScanForVisionWeighing(establishmentId));
    if (!mounted || animalId == null) return;
    try {
      final refreshed = await context.read<VisionAnimalSelectorCubit>().load();
      if (!mounted || refreshed == null) return;
      for (final animal in refreshed.animals) {
        if (animal.id == animalId && animal.establishmentId == establishmentId) {
          widget.onSelected(animal);
          return;
        }
      }
      _showMessage(VisionWeighingStrings.animalUnavailable);
    } on Exception {
      if (mounted) _showMessage(VisionWeighingStrings.animalLoadError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    color: AppColors.surface,
    elevation: AppElevation.card,
    shadowColor: AppColors.textPrimary,
    padding: const EdgeInsets.all(AppSpacing.md),
    child: BlocBuilder<VisionAnimalSelectorCubit, ResultState<VisionAnimalOptions>>(
      builder: (context, state) {
        if (state case ResultError<VisionAnimalOptions>()) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(VisionWeighingStrings.animalLoadError, style: AppTypography.formFieldError),
              AppOutlinedButton(
                label: VisionWeighingStrings.retryAnimalLoad,
                onPressed: context.read<VisionAnimalSelectorCubit>().load,
              ),
            ],
          );
        }
        final options = switch (state) {
          Data<VisionAnimalOptions>(:final data) => data,
          _ => null,
        };
        if (options == null) return const Center(child: CircularProgressIndicator());
        final establishments = options.establishments;
        final activeId =
            _establishmentId ??
            widget.selectedAnimal?.establishmentId ??
            (establishments.length == 1 ? establishments.first.id : null);
        final visibleAnimals = options.animals
            .where((animal) => activeId == null || animal.establishmentId == activeId)
            .take(5)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              VisionWeighingStrings.animalSectionTitle,
              style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(VisionWeighingStrings.animalSectionHelp, style: AppTypography.formFieldHelper),
            const SizedBox(height: AppSpacing.md),
            if (widget.selectedAnimal case final selected?) ...[
              _AnimalOption(animal: selected, selected: true, onTap: null),
              const SizedBox(height: AppSpacing.md),
            ],
            if (establishments.length > 1) ...[
              AppDropdownFormField<String>(
                key: ValueKey(activeId),
                title: VisionWeighingStrings.establishment,
                hintText: VisionWeighingStrings.selectEstablishment,
                initialValue: activeId,
                options: [
                  for (final establishment in establishments)
                    AppDropdownOption(value: establishment.id, label: establishment.name),
                ],
                onChanged: (value) {
                  setState(() => _establishmentId = value);
                  if (widget.selectedAnimal?.establishmentId != value) widget.onSelected(null);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (visibleAnimals.isEmpty)
              const Text(VisionWeighingStrings.noRecentAnimals, style: AppTypography.formFieldHelper)
            else ...[
              const Text(VisionWeighingStrings.recentAnimals, style: AppTypography.secondaryEmphasis),
              const SizedBox(height: AppSpacing.xs),
              for (final animal in visibleAnimals)
                if (animal.id != widget.selectedAnimal?.id)
                  _AnimalOption(
                    animal: animal,
                    selected: false,
                    onTap: () {
                      setState(() => _establishmentId = animal.establishmentId);
                      widget.onSelected(animal);
                    },
                  ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppOutlinedButton(
              label: VisionWeighingStrings.scanAnimal,
              icon: const Icon(Icons.nfc),
              onPressed: activeId == null ? null : () => unawaited(_scan(activeId)),
            ),
            if (establishments.isEmpty)
              const Text(VisionWeighingStrings.noEstablishments, style: AppTypography.formFieldHelper),
          ],
        );
      },
    ),
  );
}

class _AnimalOption extends StatelessWidget {
  const _AnimalOption({required this.animal, required this.selected, required this.onTap});

  final VisionAnimal animal;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Material(
      color: selected ? AppColors.backgroundSecondary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: ListTile(
        onTap: onTap,
        leading: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: AppColors.primary),
        title: Text('${VisionWeighingStrings.rfidTag}: ${animal.rfidTagNumber}', style: AppTypography.formFieldValue),
        subtitle: Text('${VisionWeighingStrings.visualTag}: ${animal.visualTag}', style: AppTypography.formFieldHelper),
      ),
    ),
  );
}
