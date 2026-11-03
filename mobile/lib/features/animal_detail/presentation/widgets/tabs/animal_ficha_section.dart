import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Título de sección de la ficha (diseño `section-title`: mayúsculas, chico).
class AnimalFichaSectionTitle extends StatelessWidget {
  /// Crea el título [text].
  const AnimalFichaSectionTitle(this.text, {super.key});

  /// Texto del título.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.formFieldHelper.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.9,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Fila clave/valor de la ficha (diseño `DataRow`).
class AnimalFichaDataRow extends StatelessWidget {
  /// Crea la fila [label] → [value].
  const AnimalFichaDataRow({
    required this.label,
    required this.value,
    super.key,
    this.isMono = false,
  });

  /// Nombre del dato.
  final String label;

  /// Valor del dato.
  final String value;

  /// Si el valor va en tipografía monoespaciada (RFID).
  final bool isMono;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTypography.formFieldHelper.copyWith(color: AppColors.textSecondary)),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: isMono
                    ? AppTypography.monoValue.copyWith(fontSize: 12)
                    : AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grupo de filas con separadores de 1 px y bordes redondeados.
class AnimalFichaDataGroup extends StatelessWidget {
  /// Crea el grupo con [rows].
  const AnimalFichaDataGroup({required this.rows, super.key});

  /// Filas del grupo.
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.border,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            for (final (index, row) in rows.indexed) ...[
              if (index > 0) const SizedBox(height: 1),
              row,
            ],
          ],
        ),
      ),
    );
  }
}

/// Pestaña todavía no desarrollada.
class AnimalFichaComingSoon extends StatelessWidget {
  /// Crea el aviso con [message].
  const AnimalFichaComingSoon({required this.icon, required this.title, required this.message, super.key});

  /// Ícono ilustrativo.
  final IconData icon;

  /// Título del aviso.
  final String title;

  /// Qué va a mostrar la pestaña.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTypography.pageTitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: AppTypography.pageBodyTitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
