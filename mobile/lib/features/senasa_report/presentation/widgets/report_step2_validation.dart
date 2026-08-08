import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Paso de validacion visual previo a la generacion del reporte SENASA.
class ReportStep2Validation extends StatelessWidget {
  /// Crea el resumen de validacion para el evento y rango seleccionados.
  const ReportStep2Validation({
    required this.startDate,
    required this.endDate,
    required this.validation,
    required this.onRetry,
    super.key,
  });

  /// Fecha inicial del periodo reportado.
  final DateTime startDate;

  /// Fecha final del periodo reportado.
  final DateTime endDate;

  /// Estado de la comprobación real realizada por el backend.
  final ResultState<SenasaValidationResult> validation;

  /// Reintenta la validación con los filtros seleccionados.
  final VoidCallback onRetry;

  Widget _buildSummaryRow(Widget icon, String label, String value) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.mediumEmphasis),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(value, style: AppTypography.mediumEmphasis),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportableAnimals = switch (validation) {
      Data<SenasaValidationResult>(data: final result) when result.issues.isEmpty => result.exportableAnimals,
      _ => null,
    };
    final formattedStart =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final formattedEnd =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          validation.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const _ValidationLoading(),
            data: (result) => _ValidationResult(result: result),
            error: (error) => _ValidationError(message: error.message, onRetry: onRetry),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xs),
            child: Text(SenasaStrings.step2SummaryTitle, style: AppTypography.pageTitle),
          ),
          AppSurfaceCard(
            elevation: 4,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxs),
              child: Column(
                children: [
                  _buildSummaryRow(
                    const Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
                    SenasaStrings.step2PeriodLabel,
                    '$formattedStart - $formattedEnd',
                  ),
                  if (exportableAnimals != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Divider(height: AppSpacing.xxxs),
                    ),
                    _buildSummaryRow(
                      SvgPicture.asset(
                        'assets/icons/cow.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      SenasaStrings.step2AnimalsLabel,
                      exportableAnimals.toString(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationResult extends StatelessWidget {
  const _ValidationResult({required this.result});

  final SenasaValidationResult result;

  @override
  Widget build(BuildContext context) {
    if (result.issues.isEmpty) {
      return const AppSuccessBanner(message: SenasaStrings.step2SuccessBanner);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            SenasaStrings.incompleteAnimals(result.issues.length),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...result.issues.map((issue) => _AnimalIssueCard(issue: issue)),
      ],
    );
  }
}

class _AnimalIssueCard extends StatelessWidget {
  const _AnimalIssueCard({required this.issue});

  final SenasaRecordIssue issue;

  @override
  Widget build(BuildContext context) {
    final tag = issue.tag?.trim();
    final identifier = tag == null || tag.isEmpty ? SenasaStrings.animalWithoutTag : tag;
    final missingFields = issue.missingFields.map(SenasaStrings.validationFieldLabel).join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        width: double.infinity,
        child: AppSurfaceCard(
          elevation: 4,
          shadowColor: Colors.black26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${SenasaStrings.tagLabel}: $identifier',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${SenasaStrings.missingFieldsLabel}: $missingFields',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationLoading extends StatelessWidget {
  const _ValidationLoading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(SenasaStrings.recordsValidationLoading)),
      ],
    );
  }
}

class _ValidationError extends StatelessWidget {
  const _ValidationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: AppSpacing.xs),
        AppOutlinedButton(label: SenasaStrings.retry, onPressed: onRetry),
      ],
    );
  }
}
