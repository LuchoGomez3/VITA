import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
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
    var draft = '';
    final note = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, rebuild) => AlertDialog(
          title: const Text(AnimalDetailStrings.addObservation),
          content: TextField(
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(hintText: AnimalDetailStrings.observationHint),
            onChanged: (value) => rebuild(() => draft = value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: draft.isEmpty ? null : () => Navigator.of(context).pop(draft),
              child: const Text(AnimalDetailStrings.saveObservation),
            ),
          ],
        ),
      ),
    );
    if (!mounted || note == null) return;
    setState(() => _saving = true);
    try {
      await widget.actions.add(widget.animal.establishmentId, widget.animal.id, note);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AnimalDetailStrings.observationSaveError)),
        );
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
      return AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final note in notes) ...[
              Text(note.text, style: AppTypography.mediumEmphasis),
              Text(DateDisplayFormatter.shortDate(note.date.toLocal()), style: AppTypography.formFieldHelper),
              if (note.status == AnimalSyncStatus.pending) const Text(AnimalDetailStrings.pendingSync),
              if (note.status == AnimalSyncStatus.rejected) const Text(AnimalDetailStrings.rejectedSyncStatus),
              const Divider(),
            ],
            if (legacy != null && legacy.isNotEmpty && !notes.any((note) => note.text == legacy))
              Text(legacy, style: AppTypography.mediumEmphasis),
            if (snapshot.hasError)
              const Text(AnimalDetailStrings.observationReadError)
            else if (notes.isEmpty && (legacy == null || legacy.isEmpty))
              const Text(AnimalDetailStrings.noDataValue, style: AppTypography.mediumEmphasis),
            TextButton.icon(
              onPressed: _saving ? null : _add,
              icon: const Icon(Icons.add),
              label: const Text(AnimalDetailStrings.addObservation),
            ),
          ],
        ),
      );
    },
  );
}
