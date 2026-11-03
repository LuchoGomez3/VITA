import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';

/// Card de una campaña de vacunación activa: nombre, fecha objetivo,
/// progreso (aplicados/objetivo) y link "Aplicar →".
class CampaignProgressCard extends StatelessWidget {
  /// Crea la card con la [campaign] y la acción de "Aplicar".
  const CampaignProgressCard({required this.campaign, required this.onApply, super.key});

  /// Campaña representada.
  final HealthCampaignMock campaign;

  /// Acción disparada al tocar "Aplicar →".
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(campaign.name, style: AppTypography.secondaryEmphasis),
              ),
              Text(campaign.targetDate, style: AppTypography.formFieldHelper),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: campaign.progress,
              minHeight: 6,
              backgroundColor: AppColors.backgroundTertiary,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${campaign.applied} / ${campaign.target} (${(campaign.progress * 100).round()}%)',
                style: AppTypography.formFieldHelper,
              ),
              GestureDetector(
                onTap: onApply,
                child: Text(
                  HealthStrings.applyLink,
                  style: AppTypography.inlinePrimaryLink.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
