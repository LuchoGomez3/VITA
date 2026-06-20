import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart'; // Ajustá la ruta según tu proyecto

/// Título y descripción reutilizable para las subsecciones de la app.
class AppSubsectionTitleAndDescription extends StatelessWidget {
  /// El título principal de la subsección.
  final String title;

  /// Descripción opcional que se muestra debajo del título.
  final String? description;

  const AppSubsectionTitleAndDescription({
    super.key,
    required this.title,
    this.description,
  });

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
              // Si hay descripción, dibuja el espacio y el texto.
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: AppTypography.mediumEmphasis,
                ),
              ],
            ],
          ),
        ),
        // Espaciado estándar hacia el siguiente elemento
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
