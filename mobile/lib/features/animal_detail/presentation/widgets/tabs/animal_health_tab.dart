import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:go_router/go_router.dart';

/// Historial sanitario de un animal y acceso al registro individual.
class AnimalHealthTab extends StatefulWidget {
  /// Construye la pestaña con el contrato de lectura de Sanidad.
  const AnimalHealthTab({required this.animal, required this.reader, super.key});

  /// Animal y establecimiento de la ficha.
  final AnimalDetail animal;

  /// Lee los eventos sanitarios locales.
  final ReadHealthUseCase reader;

  @override
  State<AnimalHealthTab> createState() => _AnimalHealthTabState();
}

class _AnimalHealthTabState extends State<AnimalHealthTab> {
  late Stream<List<HealthEvent>> _events = _watch();

  Stream<List<HealthEvent>> _watch() => widget.reader.history(widget.animal.establishmentId, widget.animal.id);

  @override
  void didUpdateWidget(AnimalHealthTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animal.id != oldWidget.animal.id || widget.animal.establishmentId != oldWidget.animal.establishmentId) {
      _events = _watch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HealthEvent>>(
      stream: _events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Center(
            child: Text(
              error is HealthFailure && error.problem == HealthProblem.unauthorized
                  ? HealthRegistrationStrings.unauthorized
                  : HealthRegistrationStrings.failed,
            ),
          );
        }
        final events = snapshot.data;
        if (events == null) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length + (events.isEmpty ? 2 : 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return FilledButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.add),
                label: const Text(HealthRegistrationStrings.register),
              );
            }
            if (events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(HealthRegistrationStrings.emptyHistory),
              );
            }
            return _HealthEventCard(
              event: events[index - 1],
              onResult: _recordResult,
              onCorrect: _correct,
            );
          },
        );
      },
    );
  }

  Future<void> _register() async {
    final saved = await context.push<bool>(
      AppRoutes.healthRegistration(
        establishmentId: widget.animal.establishmentId,
        animalId: widget.animal.id,
      ),
    );
    _showSaved(saved);
  }

  Future<void> _recordResult(HealthEvent event) async {
    final saved = await context.push<bool>(AppRoutes.healthResult, extra: event);
    _showSaved(saved);
  }

  Future<void> _correct(HealthEvent event) async {
    try {
      final rejected = await widget.reader.rejectedRegistration(event);
      if (!mounted || rejected == null) return;
      final saved = await context.push<bool>(
        AppRoutes.healthRegistration(establishmentId: event.establishmentId),
        extra: rejected,
      );
      _showSaved(saved);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(HealthRegistrationStrings.failed)));
      }
    }
  }

  void _showSaved(bool? saved) {
    if (mounted && (saved ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(HealthRegistrationStrings.saved)));
    }
  }
}

class _HealthEventCard extends StatelessWidget {
  const _HealthEventCard({required this.event, required this.onResult, required this.onCorrect});

  final HealthEvent event;
  final ValueChanged<HealthEvent> onResult;
  final ValueChanged<HealthEvent> onCorrect;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatCompactDate(event.occurredAt.toLocal());
    final isStudy = event.practice.kind == HealthPracticeKind.sampling;
    final resultStatus = _status(event.resultSyncStatus);
    final syncStatus = _status(event.syncStatus);
    final result = event.result;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.practice.name, style: Theme.of(context).textTheme.titleMedium),
            Text('$date · ${event.responsible}'),
            switch (event.details) {
              final HealthApplication details => Text(
                '${details.productName} · ${details.dose} ${details.unit} · ${details.route}',
              ),
              final HealthObservation details => Text(details.description),
            },
            if (event.details case HealthApplication(:final batch?))
              Text('${HealthRegistrationStrings.recordedBatch} · $batch'),
            if (event.details case HealthApplication(:final expirationDate?))
              Text(
                '${HealthRegistrationStrings.recordedExpiration} · ${localizations.formatCompactDate(expirationDate)}',
              ),
            if (event.details case HealthObservation(:final sampleType?)) Text(sampleType),
            if (event.recipient.sampleReference case final reference?) Text(reference),
            if (event.notes case final notes?) Text(notes),
            if (syncStatus != null) Text(syncStatus),
            if (event.syncIssue == HealthSyncIssue.animalRegistrationRejected)
              const Text(HealthRegistrationStrings.animalRegistrationRejected),
            if (event.syncStatus == HealthSyncStatus.rejected)
              TextButton(onPressed: () => onCorrect(event), child: const Text(HealthRegistrationStrings.correct)),
            if (isStudy) ...[
              Text(result?.value ?? HealthRegistrationStrings.pendingResult),
              if (result != null) Text(localizations.formatCompactDate(result.reportedAt.toLocal())),
              if (resultStatus != null) Text(resultStatus),
              if (event.resultIssue == HealthSyncIssue.resultAlreadyRecorded)
                const Text(HealthRegistrationStrings.resultConflict),
              if ((result == null || event.resultSyncStatus == HealthSyncStatus.rejected) &&
                  event.syncStatus != HealthSyncStatus.rejected)
                TextButton(onPressed: () => onResult(event), child: const Text(HealthRegistrationStrings.addResult)),
            ],
          ],
        ),
      ),
    );
  }

  static String? _status(HealthSyncStatus? status) => switch (status) {
    HealthSyncStatus.pending => HealthRegistrationStrings.pending,
    HealthSyncStatus.rejected => HealthRegistrationStrings.rejected,
    HealthSyncStatus.synchronized => HealthRegistrationStrings.synchronized,
    null => null,
  };
}
