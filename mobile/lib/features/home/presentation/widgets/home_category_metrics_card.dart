import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';

/// Muestra la distribución del inventario activo por categoría.
class HomeCategoryMetricsCard extends StatelessWidget {
  /// Crea la tarjeta con los totales y porcentajes por categoría.
  const HomeCategoryMetricsCard({required this.categories, super.key});

  /// Categorías del rodeo ordenadas para su presentación.
  final List<CategoryInventoryMetric> categories;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeStrings.categoryDistribution,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          if (categories.isEmpty)
            const Text(HomeStrings.noAnimals)
          else
            for (final category in categories) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name ?? HomeStrings.noCategory,
                      style: AppTypography.mediumEmphasis,
                    ),
                  ),
                  Text('${category.animals}'),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              LinearProgressIndicator(
                value: category.percentage,
                minHeight: AppSpacing.xxs,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                backgroundColor: AppColors.background,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}
