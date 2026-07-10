import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

/// Fila de dato dentro de una seccion de revision.
class RegisterAnimalReviewRow {
  /// Crea una fila con etiqueta y valor.
  const RegisterAnimalReviewRow({
    required this.label,
    required this.value,
  });

  /// Nombre del campo revisado.
  final String label;

  /// Valor mock o cargado para el campo.
  final String value;
}

/// Seccion reutilizable para revisar los datos cargados en un paso.
class RegisterAnimalReviewSection extends StatelessWidget {
  /// Crea una card de revision con orden, titulo, boton editar y filas.
  const RegisterAnimalReviewSection({
    required this.order,
    required this.title,
    required this.rows,
    super.key,
    this.onEdit,
    this.leading,
  });

  /// Numero de orden de la seccion.
  final int order;

  /// Titulo visible de la seccion.
  final String title;

  /// Filas de datos mostradas debajo del encabezado.
  final List<RegisterAnimalReviewRow> rows;

  /// Accion futura para editar la seccion.
  final VoidCallback? onEdit;

  /// Widget opcional que acompaña las filas, por ejemplo una caravana.
  final Widget? leading;

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
                  order.toString(),
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.pageTitle,
                ),
              ),
              InkWell(
                // TODO(agus): navegar al paso correspondiente para editar.
                onTap: onEdit,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    AnimalRegisterStrings.stepFourEditButton,
                    style: AppTypography.mediumEmphasis.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (leading == null)
            _ReviewRows(rows: rows)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading!,
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _ReviewRows(rows: rows)),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewRows extends StatelessWidget {
  const _ReviewRows({required this.rows});

  final List<RegisterAnimalReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTypography.mediumEmphasis.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      row.value,
                      style: AppTypography.mediumEmphasis.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
