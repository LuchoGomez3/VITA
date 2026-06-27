import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Título y descripción reutilizable para las subsecciones de la app.
class AppSubsectionTitleAndDescription extends StatelessWidget {
  /// Creates a subsection heading with an optional description.
  const AppSubsectionTitleAndDescription({
    required this.title,
    super.key,
    this.description,
  });

  /// El título principal de la subsección.
  final String title;

  /// Descripción opcional que se muestra debajo del título.
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.pageTitle,
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: AppTypography.mediumEmphasis.copyWith(color: AppColors.textHint),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
