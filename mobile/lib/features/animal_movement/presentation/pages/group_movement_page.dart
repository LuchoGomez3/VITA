import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/group_movement_state.dart';
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
  int _tagRevision = 0;

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagEdited);
  }

  void _onTagEdited() => _tagRevision++;

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocus.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final tag = _tagController.text;
    _tagRevision++;
    _tagController.clear();
    final revision = _tagRevision;
    // Cada Enter entrega una captura independiente al Cubit y deja el campo
    // listo para la siguiente lectura antes de consultar SQLite.
    _tagFocus.requestFocus();
    final added = await context.read<GroupMovementCubit>().addTag(tag);
    if (!mounted) return;
    if (!added && revision == _tagRevision) {
      _tagController.value = TextEditingValue(
        text: tag,
        selection: TextSelection.collapsed(offset: tag.length),
      );
    }
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
      listenWhen: (previous, current) =>
          previous.submission is! Data<GroupMovementSummary> && current.submission is Data<GroupMovementSummary>,
      listener: (context, state) {
        if (state.submission case Data<GroupMovementSummary>(:final data)) {
          context.pop(data);
        }
      },
      builder: (context, state) {
        final saving = state.submission is Loading<GroupMovementSummary>;
        final hasSavedChanges = state.savedSummary.movedCount > 0;
        return PopScope<GroupMovementSummary>(
          canPop: !saving && !hasSavedChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && !saving && hasSavedChanges) {
              context.pop(state.savedSummary);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              centerTitle: true,
              title: const Text(AnimalMovementStrings.pageTitle, style: AppTypography.appBarTitle),
            ),
            body: switch (state.preparation) {
              Data<GroupMovementPreparation>() => AbsorbPointer(
                absorbing: state.submission is Loading<GroupMovementSummary>,
                child: _GroupMovementForm(
                  state: state,
                  onAddTag: _addTag,
                  tagController: _tagController,
                  tagFocus: _tagFocus,
                  reasonController: _reasonController,
                  onPickDate: _pickDate,
                ),
              ),
              ResultError<GroupMovementPreparation>(:final error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    AnimalMovementStrings.errorMessage(error),
                    textAlign: TextAlign.center,
                    style: AppTypography.pageBodyTitle,
                  ),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
            bottomNavigationBar: state.preparation is! Data<GroupMovementPreparation>
                ? null
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
                      child: AppFilledButton(
                        label: AnimalMovementStrings.submit(
                          state.destinationId == null ? state.animals.length : state.movableCount,
                        ),
                        isLoading: state.submission is Loading<GroupMovementSummary>,
                        onPressed:
                            state.animals.isEmpty ||
                                state.submission is Loading<GroupMovementSummary> ||
                                state.tagResolution is Loading<MovementAnimal>
                            ? null
                            : () => context.read<GroupMovementCubit>().submit(_reasonController.text),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _GroupMovementForm extends StatelessWidget {
  const _GroupMovementForm({
    required this.state,
    required this.onAddTag,
    required this.tagController,
    required this.tagFocus,
    required this.reasonController,
    required this.onPickDate,
  });

  final GroupMovementState state;
  final Future<void> Function() onAddTag;
  final TextEditingController tagController;
  final FocusNode tagFocus;
  final TextEditingController reasonController;
  final Future<void> Function(DateTime) onPickDate;

  @override
  Widget build(BuildContext context) {
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
                controller: tagController,
                focusNode: tagFocus,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAddTag(),
                style: AppTypography.formFieldValue,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: AnimalMovementStrings.tagFieldHint,
                  prefixIcon: const Icon(Icons.contactless_outlined, color: AppColors.textHint),
                  errorText: switch (state.tagResolution) {
                    ResultError<MovementAnimal>(:final error) => AnimalMovementStrings.errorMessage(error),
                    _ => null,
                  },
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(
              tooltip: AnimalMovementStrings.addTag,
              onPressed: onAddTag,
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
          controller: reasonController,
          title: AnimalMovementStrings.reasonLabel,
          hintText: AnimalMovementStrings.reasonHint,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => onPickDate(occurredAt),
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(AnimalMovementStrings.dateLabel(DateDisplayFormatter.shortDate(occurredAt))),
        ),
        if (state.submission case ResultError<GroupMovementSummary>(:final error)) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(AnimalMovementStrings.errorMessage(error), style: AppTypography.errorBody),
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
