import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/withdrawal_callout.dart';

/// Card de un tratamiento en curso, con banner de carencia activa cuando
/// [TreatmentMock.withdrawalNote] no es nulo.
class TreatmentCard extends StatelessWidget {
  /// Crea la card con el [treatment] en curso.
  const TreatmentCard({required this.treatment, super.key});

  /// Tratamiento representado.
  final TreatmentMock treatment;

  @override
  Widget build(BuildContext context) {
    final withdrawalNote = treatment.withdrawalNote;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${treatment.name} · lote ${treatment.batch}', style: AppTypography.secondaryEmphasis),
          const SizedBox(height: AppSpacing.xxs),
          Text(treatment.detail, style: AppTypography.formFieldHelper),
          if (withdrawalNote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppStatusChip(label: HealthStrings.withdrawalActiveLabel, showDot: true),
            const SizedBox(height: AppSpacing.xs),
            WithdrawalCallout(message: withdrawalNote),
          ],
        ],
      ),
    );
  }
}
