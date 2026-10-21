import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:go_router/go_router.dart';

/// Factory del cubit de "Mover animales".
typedef GroupMovementCubitFactory = GroupMovementCubit Function();

/// "Mover animales": se arma la lista leyendo las caravanas de los animales que
/// se van a mover, se elige el potrero de destino y se registra todo junto.
///
/// El bastón RFID funciona como un teclado: escribe el número en el campo y
/// manda Enter, así que leer una caravana y tipearla siguen el mismo camino.
/// Funciona sin conexión: el movimiento se guarda en el celular y se sincroniza
/// después. Devuelve el [GroupMovementSummary] al cerrar.
class GroupMovementPage extends StatelessWidget {
  /// Crea la pantalla arrancando con [animalId] en la lista.
  const GroupMovementPage({required this.animalId, required this.createCubit, super.key});

  /// Animal desde cuya ficha se abrió.
  final String animalId;

  /// Crea el cubit con sus dependencias.
  final GroupMovementCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..start(animalId),
      child: const _GroupMovementView(),
    );
  }
}

class _GroupMovementView extends StatefulWidget {
  const _GroupMovementView();

  @override
  State<_GroupMovementView> createState() => _GroupMovementViewState();
}

class _GroupMovementViewState extends State<_GroupMovementView> {
  final _tagController = TextEditingController();
  final _tagFocus = FocusNode();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocus.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final added = await context.read<GroupMovementCubit>().addTag(_tagController.text);
    if (added) {
      _tagController.clear();
    }
    // El bastón lee una caravana tras otra: el foco vuelve al campo.
    if (mounted) _tagFocus.requestFocus();
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      context.read<GroupMovementCubit>().selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupMovementCubit, GroupMovementState>(
      listenWhen: (previous, current) => previous.summary == null && current.summary != null,
      listener: (context, state) => context.pop(state.summary),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            centerTitle: true,
            title: const Text(AnimalMovementStrings.pageTitle, style: AppTypography.appBarTitle),
          ),
          body: switch (state) {
            GroupMovementState(isLoading: true) => const Center(child: CircularProgressIndicator()),
            GroupMovementState(:final loadError?) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(loadError, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
              ),
            ),
            _ => _buildForm(context, state),
          },
          bottomNavigationBar: state.isLoading || state.loadError != null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
                    child: AppFilledButton(
                      label: AnimalMovementStrings.submit(
                        state.destinationId == null ? state.animals.length : state.movableCount,
                      ),
                      isLoading: state.isSubmitting,
                      onPressed: state.animals.isEmpty || state.isSubmitting
                          ? null
                          : () => context.read<GroupMovementCubit>().submit(_reasonController.text),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, GroupMovementState state) {
    final cubit = context.read<GroupMovementCubit>();
    final occurredAt = state.occurredAt ?? DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Text(AnimalMovementStrings.readHint, style: AppTypography.formFieldHelper),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                focusNode: _tagFocus,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTag(),
                style: AppTypography.formFieldValue,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: AnimalMovementStrings.tagFieldHint,
                  prefixIcon: const Icon(Icons.contactless_outlined, color: AppColors.textHint),
                  errorText: state.tagError,
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(
              tooltip: AnimalMovementStrings.addTag,
              onPressed: _addTag,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(AnimalMovementStrings.animalsTitle(state.animals.length), style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        for (final animal in state.animals)
          _AnimalRow(
            animal: animal,
            isAlreadyThere: animal.lotId == state.destinationId,
            onRemove: () => cubit.remove(animal.id),
          ),
        const SizedBox(height: AppSpacing.lg),
        const Text(AnimalMovementStrings.destinationTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        if (state.destinations.isEmpty)
          const Text(AnimalMovementStrings.noDestinations, style: AppTypography.formFieldHelper)
        else
          for (final destination in state.destinations)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppSelectableCard<String>(
                value: destination.id,
                groupValue: state.destinationId,
                title: destination.name,
                subtitle: AnimalMovementStrings.destinationAnimals(destination.animalCount),
                icon: Icons.grass_outlined,
                onChanged: cubit.selectDestination,
              ),
            ),
        const SizedBox(height: AppSpacing.md),
        AppTextFormField(
          controller: _reasonController,
          title: AnimalMovementStrings.reasonLabel,
          hintText: AnimalMovementStrings.reasonHint,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => _pickDate(occurredAt),
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(AnimalMovementStrings.dateLabel(DateDisplayFormatter.shortDate(occurredAt))),
        ),
        if (state.submitError case final error?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(error, style: AppTypography.errorBody),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _AnimalRow extends StatelessWidget {
  const _AnimalRow({required this.animal, required this.isAlreadyThere, required this.onRemove});

  final MovementAnimal animal;
  final bool isAlreadyThere;
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
                  Text(
                    isAlreadyThere
                        ? AnimalMovementStrings.alreadyInDestination
                        : AnimalMovementStrings.fromLot(animal.lotName),
                    style: AppTypography.formFieldHelper,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: AnimalMovementStrings.removeAnimal,
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
