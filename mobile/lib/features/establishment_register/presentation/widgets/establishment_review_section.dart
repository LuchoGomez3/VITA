import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Fila de dato dentro de una sección de revisión del establecimiento.
class EstablishmentReviewRow {
  /// Crea una fila con etiqueta y valor.
  const EstablishmentReviewRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.isMuted = false,
  });

  /// Nombre del campo revisado.
  final String label;

  /// Valor cargado para el campo.
  final String value;

  /// Si el valor se muestra con tipografia monoespaciada (ej. CUIT, RENSPA).
  final bool isMono;

  /// Si el valor se muestra con color atenuado.
  final bool isMuted;
}

/// Sección reutilizable para revisar los datos cargados en un paso.
class EstablishmentReviewSection extends StatelessWidget {
  /// Crea una card de revisión con orden, título, filas y botón editar.
  const EstablishmentReviewSection({
    required this.order,
    required this.title,
    required this.rows,
    super.key,
    this.onEdit,
    this.trailing,
  });

  /// Número de orden de la sección.
  final int order;

  /// Título visible de la sección.
  final String title;

  /// Filas de datos mostradas debajo del encabezado.
  final List<EstablishmentReviewRow> rows;

  /// Acción para volver al paso correspondiente y editarlo.
  final VoidCallback? onEdit;

  /// Contenido adicional mostrado debajo de las filas (ej. mapa, chips).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$order',
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.onPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(title, style: AppTypography.pageTitle),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Text(
                      EstablishmentRegisterStrings.reviewEditButton,
                      style: AppTypography.mediumEmphasis.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTypography.formFieldHelper,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      row.value,
                      style: (row.isMono ? AppTypography.monoValueEmphasis : AppTypography.mediumEmphasis).copyWith(
                        color: row.isMuted ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(height: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
