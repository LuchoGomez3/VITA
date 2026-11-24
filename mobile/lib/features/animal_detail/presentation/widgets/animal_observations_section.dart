import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/animal_observations.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Notas registradas y acción para agregar una observación desde la ficha.
class AnimalObservationsSection extends StatefulWidget {
  /// Abre las observaciones del animal, incluidas las notas pendientes.
  const AnimalObservationsSection({required this.animal, required this.actions, super.key});

  /// Identidad del animal y texto anterior, cuando existe.
  final AnimalDetail animal;

  /// Casos de uso de lectura y alta.
  final AnimalObservations actions;

  @override
  State<AnimalObservationsSection> createState() => _AnimalObservationsSectionState();
}

class _AnimalObservationsSectionState extends State<AnimalObservationsSection> {
  late final Stream<List<AnimalObservation>> _notes = widget.actions.watch(
    widget.animal.establishmentId,
    widget.animal.id,
  );
  bool _saving = false;

  Future<void> _add() async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ObservationComposer(),
    );
    if (!mounted || note == null) return;
    setState(() => _saving = true);
    try {
      await widget.actions.add(widget.animal.establishmentId, widget.animal.id, note);
    } on Exception {
      if (mounted) {
        AppToastHost.show(context, AnimalDetailStrings.observationSaveError);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<AnimalObservation>>(
    stream: _notes,
    builder: (context, snapshot) {
      final legacy = widget.animal.observations;
      final notes = snapshot.data ?? const <AnimalObservation>[];
      final showLegacy = legacy != null && legacy.isNotEmpty && !notes.any((note) => note.text == legacy);
      return AppSurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(AnimalDetailStrings.observationsLabel, style: AppTypography.mediumEmphasis),
                ),
                TextButton.icon(
                  onPressed: _saving ? null : _add,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(AnimalDetailStrings.addObservationAction),
                ),
              ],
            ),
            if (snapshot.hasError)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text(AnimalDetailStrings.observationReadError, style: AppTypography.formFieldHelper),
              )
            else if (notes.isEmpty && !showLegacy && snapshot.connectionState != ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text(AnimalDetailStrings.noObservations, style: AppTypography.formFieldHelper),
              ),
            for (final note in notes) _ObservationEntry(text: note.text, note: note),
            if (showLegacy) _ObservationEntry(text: legacy),
          ],
        ),
      );
    },
  );
}

class _ObservationComposer extends StatefulWidget {
  const _ObservationComposer();

  @override
  State<_ObservationComposer> createState() => _ObservationComposerState();
}

class _ObservationComposerState extends State<_ObservationComposer> {
  String _draft = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(AnimalDetailStrings.addObservation, style: AppTypography.appBarTitle),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: AnimalDetailStrings.observationHint,
                  filled: true,
                  fillColor: AppColors.background,
                ),
                onChanged: (value) => setState(() => _draft = value.trim()),
              ),
              const SizedBox(height: AppSpacing.md),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: AppSpacing.xs,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AnimalDetailStrings.cancelObservation),
                  ),
                  FilledButton(
                    onPressed: _draft.isEmpty ? null : () => Navigator.of(context).pop(_draft),
                    child: const Text(AnimalDetailStrings.saveObservation),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObservationEntry extends StatelessWidget {
  const _ObservationEntry({required this.text, this.note});

  final String text;
  final AnimalObservation? note;

  @override
  Widget build(BuildContext context) {
    final observation = note;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (observation != null) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xxxs,
              children: [
                Text(
                  DateDisplayFormatter.shortDate(observation.date.toLocal()),
                  style: AppTypography.smallEmphasis,
                ),
                if (observation.status == AnimalSyncStatus.pending)
                  const Text(
                    AnimalDetailStrings.pendingSync,
                    style: TextStyle(color: AppColors.syncPending, fontSize: 12),
                  ),
                if (observation.status == AnimalSyncStatus.rejected)
                  const Text(
                    AnimalDetailStrings.rejectedSyncStatus,
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
          ],
          Text(text, style: AppTypography.formFieldValue),
        ],
      ),
    );
  }
}
