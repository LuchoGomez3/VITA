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
      child: Row(
        children: [
          const HomeAssetIcon(
            assetPath: 'assets/icons/arrow_right_alt.svg',
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomeStrings.averageDailyGain,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  dailyGain == null ? HomeStrings.noData : '${dailyGain.toStringAsFixed(2)} kg/día',
                  style: AppTypography.bigTitle,
                ),
                Text(
                  '${dashboard.animalsWithDailyGain} '
                  '${HomeStrings.animalsWithHistory}',
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
