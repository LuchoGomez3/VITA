import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/catalogs/feeding_catalog.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';
import 'package:frontend_mayoral/features/feeding/presentation/cubit/register_feeding_cubit.dart';
import 'package:frontend_mayoral/features/feeding/presentation/strings/feeding_strings.dart';
import 'package:frontend_mayoral/features/feeding/presentation/widgets/food_quick_add_dialog.dart';
import 'package:go_router/go_router.dart';

/// Factory del cubit del registro.
typedef RegisterFeedingCubitFactory = RegisterFeedingCubit Function();

/// Valor de la opción "Corral o manga" en la lista de potreros.
const _noLot = '';

/// "Registrar alimentación": un suplemento o dieta para uno o varios animales.
///
/// Arranca con [animalIds] y se suman más leyendo caravanas (el bastón RFID
/// escribe el número y manda Enter, igual que en "Mover animales"). Funciona
/// sin conexión. Al guardar vuelve con la cantidad de animales registrados.
class RegisterFeedingPage extends StatelessWidget {
  /// Crea la pantalla.
  const RegisterFeedingPage({required this.animalIds, required this.createCubit, super.key});

  /// Animales con los que arranca.
  final List<String> animalIds;

  /// Crea el cubit con sus dependencias.
  final RegisterFeedingCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..start(animalIds),
      child: const _RegisterFeedingView(),
    );
  }
}

class _RegisterFeedingView extends StatefulWidget {
  const _RegisterFeedingView();

  @override
  State<_RegisterFeedingView> createState() => _RegisterFeedingViewState();
}

class _RegisterFeedingViewState extends State<_RegisterFeedingView> {
  final _tagController = TextEditingController();
  final _tagFocus = FocusNode();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocus.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final tag = _tagController.text;
    _tagController.clear();
    _tagFocus.requestFocus();
    final added = await context.read<RegisterFeedingCubit>().addTag(tag);
    if (!added && mounted && _tagController.text.isEmpty) {
      _tagController.value = TextEditingValue(
        text: tag,
        selection: TextSelection.collapsed(offset: tag.length),
      );
    }
  }

  Future<void> _addFood(List<Food> foods) async {
    final cubit = context.read<RegisterFeedingCubit>();
    final result = await showDialog<FoodQuickAddResult>(
      context: context,
      builder: (_) => FoodQuickAddDialog(foods: foods),
    );
    switch (result) {
      case ExistingFoodPicked(:final foodId):
        cubit.selectFood(foodId);
      case NewFoodCreated(:final food):
        cubit.useNewFood(food);
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterFeedingCubit, RegisterFeedingState>(
      listenWhen: (previous, current) => previous.submission is! Data<int> && current.submission is Data<int>,
      listener: (context, state) {
        if (state.submission case Data<int>(:final data)) context.pop(data);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            centerTitle: true,
            title: const Text(FeedingStrings.pageTitle, style: AppTypography.appBarTitle),
          ),
          body: switch (state.preparation) {
            Data<FeedingFormData>() => AbsorbPointer(
              absorbing: state.isSaving,
              child: _RegisterFeedingForm(
                state: state,
                tagController: _tagController,
                tagFocus: _tagFocus,
                quantityController: _quantityController,
                reasonController: _reasonController,
                onAddTag: _addTag,
                onAddFood: () => _addFood(state.foods),
              ),
            ),
            ResultError<FeedingFormData>(:final error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(error.message, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          bottomNavigationBar: state.preparation is! Data<FeedingFormData>
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
                    child: AppFilledButton(
                      label: FeedingStrings.submit(state.animals.length),
                      isLoading: state.isSaving,
                      onPressed: state.animals.isEmpty || !state.hasFood || state.isSaving
                          ? null
                          : () => context.read<RegisterFeedingCubit>().submit(
                              quantityText: _quantityController.text,
                              reason: _reasonController.text,
                            ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _RegisterFeedingForm extends StatelessWidget {
  const _RegisterFeedingForm({
    required this.state,
    required this.tagController,
    required this.tagFocus,
    required this.quantityController,
    required this.reasonController,
    required this.onAddTag,
    required this.onAddFood,
  });

  final RegisterFeedingState state;
  final TextEditingController tagController;
  final FocusNode tagFocus;
  final TextEditingController quantityController;
  final TextEditingController reasonController;
  final Future<void> Function() onAddTag;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterFeedingCubit>();
    final newFood = state.newFood;
    final today = DateUtils.dateOnly(DateTime.now());
    final start = state.startDate ?? today;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // ------------------------------------------------------------ animales
        const Text(FeedingStrings.readHint, style: AppTypography.formFieldHelper),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                focusNode: tagFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAddTag(),
                style: AppTypography.formFieldValue,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: FeedingStrings.tagFieldHint,
                  prefixIcon: const Icon(Icons.contactless_outlined, color: AppColors.textHint),
                  errorText: switch (state.tagResolution) {
                    ResultError<FeedingAnimal>(:final error) => error.message,
                    _ => null,
                  },
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(tooltip: FeedingStrings.addTag, onPressed: onAddTag, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(FeedingStrings.animalsTitle(state.animals.length), style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        for (final animal in state.animals) _AnimalRow(animal: animal, onRemove: () => cubit.remove(animal.id)),
        const SizedBox(height: AppSpacing.lg),

        // ---------------------------------------------------------------- tipo
        AppSegmentedFormField<FeedingType>(
          title: FeedingStrings.typeTitle,
          value: state.type,
          options: const [
            AppSegmentedOption(value: FeedingType.supplement, label: FeedingStrings.supplement),
            AppSegmentedOption(value: FeedingType.diet, label: FeedingStrings.diet),
          ],
          onChanged: cubit.selectType,
        ),
        const SizedBox(height: AppSpacing.xxs),
        const Text(FeedingStrings.typeHelper, style: AppTypography.formFieldHelper),
        const SizedBox(height: AppSpacing.lg),

        // ------------------------------------------------------------ alimento
        if (state.foods.isEmpty && newFood == null)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(FeedingStrings.noFoods, style: AppTypography.formFieldHelper),
          )
        else
          AppDropdownFormField<String>(
            // La key fuerza el rearmado cuando el alimento cambia desde afuera
            // (alta rápida o coincidencia elegida en el diálogo).
            key: ValueKey('${state.foodId}-${newFood?.name}'),
            title: FeedingStrings.foodTitle,
            hintText: FeedingStrings.foodHint,
            initialValue: newFood != null ? _newFoodKey : state.foodId,
            icon: const Icon(Icons.grain_outlined, color: AppColors.primary),
            options: [
              if (newFood != null)
                AppDropdownOption(value: _newFoodKey, label: FeedingStrings.newFoodSelected(newFood.name)),
              for (final food in state.foods)
                AppDropdownOption(
                  value: food.id,
                  label: '${food.name} · ${FeedingCatalog.categoryLabel(food.categoryCode)}',
                ),
            ],
            onChanged: (value) {
              if (value != null && value != _newFoodKey) cubit.selectFood(value);
            },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddFood,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(FeedingStrings.newFoodCta),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // --------------------------------------------------------------- lugar
        const Text(FeedingStrings.lotTitle, style: AppTypography.secondaryEmphasis),
        const SizedBox(height: AppSpacing.xs),
        for (final lot in state.lots)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppSelectableCard<String>(
              value: lot.id,
              groupValue: state.lotId ?? _noLot,
              title: lot.name,
              subtitle: FeedingStrings.lotHelper,
              icon: Icons.grass_outlined,
              onChanged: cubit.selectLot,
            ),
          ),
        AppSelectableCard<String>(
          value: _noLot,
          groupValue: state.lotId ?? _noLot,
          title: FeedingStrings.noLot,
          subtitle: FeedingStrings.noLotHelper,
          icon: Icons.fence_outlined,
          onChanged: (_) => cubit.selectLot(null),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ------------------------------------------------------------ cantidad
        const Text(FeedingStrings.quantityTitle, style: AppTypography.secondaryEmphasis),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextFormField(
                controller: quantityController,
                hintText: FeedingStrings.quantityHint,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppDropdownFormField<String>(
                key: ValueKey('unit-${state.unitCode}'),
                hintText: FeedingStrings.unitLabel,
                initialValue: state.unitCode,
                options: [
                  for (final option in FeedingCatalog.units)
                    AppDropdownOption(value: option.code, label: option.displayName),
                ],
                onChanged: (value) {
                  if (value != null) cubit.selectUnit(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSegmentedFormField<FeedingQuantityBasis>(
          value: state.basis,
          options: const [
            AppSegmentedOption(value: FeedingQuantityBasis.perAnimalDay, label: FeedingStrings.perAnimalDay),
            AppSegmentedOption(value: FeedingQuantityBasis.groupDay, label: FeedingStrings.groupDay),
          ],
          onChanged: cubit.selectBasis,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ------------------------------------------------------------ duración
        AppSegmentedFormField<FeedingDuration>(
          title: FeedingStrings.durationTitle,
          value: state.duration,
          options: const [
            AppSegmentedOption(value: FeedingDuration.oneDay, label: FeedingStrings.oneDay),
            AppSegmentedOption(value: FeedingDuration.period, label: FeedingStrings.period),
            AppSegmentedOption(value: FeedingDuration.ongoing, label: FeedingStrings.ongoing),
          ],
          onChanged: cubit.selectDuration,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppDateFormField(
          title: state.duration == FeedingDuration.oneDay ? FeedingStrings.dayLabel : FeedingStrings.startLabel,
          hintText: FeedingStrings.dateHint,
          value: start,
          lastDate: today,
          onChanged: (date) => cubit.selectStart(DateUtils.dateOnly(date)),
        ),
        if (state.duration == FeedingDuration.period) ...[
          const SizedBox(height: AppSpacing.sm),
          AppDateFormField(
            title: FeedingStrings.endLabel,
            hintText: FeedingStrings.dateHint,
            value: state.endDate ?? start,
            firstDate: start,
            onChanged: (date) => cubit.selectEnd(DateUtils.dateOnly(date)),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        // -------------------------------------------------------------- motivo
        AppTextFormField(
          controller: reasonController,
          title: FeedingStrings.reasonLabel,
          hintText: FeedingStrings.reasonHint,
        ),
        if (state.submission case ResultError<int>(:final error)) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(error.message, style: AppTypography.errorBody),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  static const _newFoodKey = '__nuevo__';
}

class _AnimalRow extends StatelessWidget {
  const _AnimalRow({required this.animal, required this.onRemove});

  final FeedingAnimal animal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final description = [animal.breed, animal.categoryName].where((part) => part.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppSurfaceCard(
        elevation: 0,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            AppEarTagBadge(visualTag: animal.visualTag),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty) Text(description, style: AppTypography.mediumEmphasis),
                  Text(FeedingStrings.inLot(animal.lotName), style: AppTypography.formFieldHelper),
                ],
              ),
            ),
            IconButton(
              tooltip: FeedingStrings.removeAnimal,
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
