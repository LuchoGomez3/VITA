import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/catalogs/feeding_catalog.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';
import 'package:frontend_mayoral/features/feeding/presentation/strings/feeding_strings.dart';

/// Lo que devuelve el diálogo: un alimento existente o uno nuevo.
sealed class FoodQuickAddResult {
  const FoodQuickAddResult();
}

/// Se eligió una coincidencia del catálogo en vez de crear un duplicado.
class ExistingFoodPicked extends FoodQuickAddResult {
  /// Crea el resultado.
  const ExistingFoodPicked(this.foodId);

  /// Alimento elegido.
  final String foodId;
}

/// Se dio de alta un alimento nuevo (se guarda junto con el registro).
class NewFoodCreated extends FoodQuickAddResult {
  /// Crea el resultado.
  const NewFoodCreated(this.food);

  /// Datos del alimento.
  final NewFoodInput food;
}

/// Alta rápida de un alimento sin salir del registro.
///
/// Mientras se escribe muestra los alimentos parecidos: sin señal no hay forma
/// de saber si otro dispositivo ya lo cargó, así que se evita el duplicado acá.
class FoodQuickAddDialog extends StatefulWidget {
  /// Crea el diálogo sobre el catálogo [foods].
  const FoodQuickAddDialog({required this.foods, super.key});

  /// Catálogo actual.
  final List<Food> foods;

  @override
  State<FoodQuickAddDialog> createState() => _FoodQuickAddDialogState();
}

class _FoodQuickAddDialogState extends State<FoodQuickAddDialog> {
  final _nameController = TextEditingController();
  String _categoryCode = FeedingCatalog.categories.first.code;
  String _unitCode = FeedingCatalog.units.first.code;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<Food> get _similar {
    final query = _nameController.text.trim().toLowerCase();
    if (query.length < 2) return const [];
    return widget.foods.where((food) => food.name.toLowerCase().contains(query)).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final similar = _similar;
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text(FeedingStrings.newFoodTitle, style: AppTypography.pageTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextFormField(
              controller: _nameController,
              title: FeedingStrings.foodNameLabel,
              hintText: FeedingStrings.foodNameHint,
              textInputAction: TextInputAction.done,
            ),
            if (similar.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const Text(FeedingStrings.similarFoods, style: AppTypography.formFieldHelper),
              const SizedBox(height: AppSpacing.xxs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final food in similar)
                    ActionChip(
                      avatar: const Icon(Icons.check, size: 16, color: AppColors.primary),
                      label: Text(food.name, style: AppTypography.smallEmphasis),
                      backgroundColor: AppColors.backgroundSecondaryLight,
                      side: const BorderSide(color: AppColors.backgroundSecondary),
                      onPressed: () => Navigator.pop(context, ExistingFoodPicked(food.id)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppDropdownFormField<String>(
              title: FeedingStrings.categoryLabel,
              hintText: FeedingStrings.categoryLabel,
              initialValue: _categoryCode,
              options: [
                for (final option in FeedingCatalog.categories)
                  AppDropdownOption(value: option.code, label: option.displayName),
              ],
              onChanged: (value) {
                if (value != null) _categoryCode = value;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppChoiceSelector<String>(
              title: FeedingStrings.unitLabel,
              value: _unitCode,
              options: [
                for (final option in FeedingCatalog.units)
                  AppChoiceOption(value: option.code, label: option.displayName),
              ],
              onChanged: (value) => setState(() => _unitCode = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(FeedingStrings.cancel)),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  NewFoodCreated(
                    NewFoodInput(name: _nameController.text.trim(), categoryCode: _categoryCode, unitCode: _unitCode),
                  ),
                ),
          child: const Text(FeedingStrings.useFood),
        ),
      ],
    );
  }
}
