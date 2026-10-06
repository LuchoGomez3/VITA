import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';

/// Presenta la ganancia diaria promedio y la cobertura del cálculo.
class HomeDailyGainCard extends StatelessWidget {
  /// Crea la tarjeta de ganancia diaria con los datos consolidados del tablero.
  const HomeDailyGainCard({required this.dashboard, super.key});

  /// Indicadores utilizados para mostrar el valor y su cobertura.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final dailyGain = dashboard.averageDailyGainKg;

    return AppSurfaceCard(
      // Mantiene la misma profundidad visual que las tarjetas de gastos.
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeAssetIcon(
            assetPath: 'assets/icons/arrow_right_alt.svg',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dailyGain == null ? HomeStrings.noData : dailyGain.toStringAsFixed(2),
            style: AppTypography.bigTitle,
          ),
          const Text(
            HomeStrings.averageDailyGain,
            style: AppTypography.mediumEmphasis,
          ),
          const Text(
            HomeStrings.dailyGainUnit,
            style: AppTypography.smallEmphasis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${dashboard.animalsWithDailyGain} ${HomeStrings.animalsWithHistory}',
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
