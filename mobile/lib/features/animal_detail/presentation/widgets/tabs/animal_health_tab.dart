import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
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
          padding: const EdgeInsets.all(AppSpacing.md),
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
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
    await context.push<bool>(
      AppRoutes.healthRegistration(
        establishmentId: widget.animal.establishmentId,
        animalId: widget.animal.id,
      ),
    );
  }

  Future<void> _recordResult(HealthEvent event) async {
    final saved = await context.push<bool>(AppRoutes.healthResult, extra: event);
    if (mounted && (saved ?? false)) {
      AppToastHost.show(context, HealthRegistrationStrings.saved, tone: AppToastTone.success);
    }
  }

  Future<void> _correct(HealthEvent event) async {
    try {
      final rejected = await widget.reader.rejectedRegistration(event);
      if (!mounted || rejected == null) return;
      await context.push<bool>(
        AppRoutes.healthRegistration(establishmentId: event.establishmentId),
        extra: rejected,
      );
    } on Object {
      if (mounted) {
        AppToastHost.show(context, HealthRegistrationStrings.failed);
      }
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
    final date = DateDisplayFormatter.shortDate(event.occurredAt.toLocal());
    final isStudy = event.practice.kind == HealthPracticeKind.sampling;
    final result = event.result;
    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.practice.name, style: AppTypography.pageBodyTitle),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text('$date · ${event.responsible}', style: AppTypography.formFieldHelper),
            ),
            const Divider(height: AppSpacing.lg),
            if (event.details case final HealthApplication details) ...[
              Text(details.productName, style: AppTypography.mediumEmphasis),
              _HealthDetail(HealthRegistrationStrings.dose, '${details.dose} ${details.unit}'),
              _HealthDetail(HealthRegistrationStrings.route, details.route),
              if (details.batch case final batch?) _HealthDetail(HealthRegistrationStrings.recordedBatch, batch),
              if (details.expirationDate case final expiration?)
                _HealthDetail(HealthRegistrationStrings.recordedExpiration, DateDisplayFormatter.shortDate(expiration)),
            ],
            if (event.details case final HealthObservation details) ...[
              Text(details.description, style: AppTypography.pageBodyTitle),
              if (details.sampleType case final sampleType?)
                _HealthDetail(HealthRegistrationStrings.sampleType, sampleType),
            ],
            if (event.recipient.sampleReference case final reference?)
              _HealthDetail(HealthRegistrationStrings.recordedSampleReference, reference),
            if (event.notes case final notes?) _HealthDetail(HealthRegistrationStrings.recordedNotes, notes),
            _HealthSyncStatus(event.syncStatus),
            if (event.syncIssue == HealthSyncIssue.animalRegistrationRejected)
              const Text(HealthRegistrationStrings.animalRegistrationRejected),
            if (event.syncStatus == HealthSyncStatus.rejected)
              TextButton(onPressed: () => onCorrect(event), child: const Text(HealthRegistrationStrings.correct)),
            if (isStudy) ...[
              const Divider(height: AppSpacing.lg),
              if (result == null)
                const Text(HealthRegistrationStrings.pendingResult, style: AppTypography.mediumEmphasis)
              else ...[
                _HealthDetail(HealthRegistrationStrings.result, result.value),
                _HealthDetail(
                  HealthRegistrationStrings.resultDate,
                  DateDisplayFormatter.shortDate(result.reportedAt.toLocal()),
                ),
              ],
              if (event.resultSyncStatus case final status?) _HealthSyncStatus(status),
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
}

class _HealthDetail extends StatelessWidget {
  const _HealthDetail(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xxs),
    child: Text.rich(
      TextSpan(
        style: AppTypography.formFieldValue,
        children: [
          TextSpan(text: '$label · ', style: AppTypography.secondaryEmphasis),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

class _HealthSyncStatus extends StatelessWidget {
  const _HealthSyncStatus(this.status);

  final HealthSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color, background) = switch (status) {
      HealthSyncStatus.pending => (
        HealthRegistrationStrings.pending,
        Icons.schedule,
        AppColors.syncPending,
        AppColors.syncPendingContainer,
      ),
      HealthSyncStatus.rejected => (
        HealthRegistrationStrings.rejected,
        Icons.error_outline,
        AppColors.error,
        AppColors.errorContainer,
      ),
      HealthSyncStatus.synchronized => (
        HealthRegistrationStrings.synchronized,
        Icons.check_circle_outline,
        AppColors.primaryDark,
        AppColors.backgroundSecondaryLight,
      ),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(label, style: AppTypography.smallEmphasis.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
