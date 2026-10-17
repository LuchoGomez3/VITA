import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Agrupa datos en dos columnas y usa una sola con poco espacio o texto grande.
/// Wrap permite que cada fila crezca sin recortar los valores largos.
class EstablishmentDetailsGrid extends StatelessWidget {
  /// Crea la grilla con los pares etiqueta/valor.
  const EstablishmentDetailsGrid({required this.fields, super.key});

  /// Datos a mostrar, en orden de lectura.
  final List<({String label, String value})> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 280 || MediaQuery.textScalerOf(context).scale(16) > 24;
        final width = useSingleColumn ? constraints.maxWidth : (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.lg,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.label, style: AppTypography.formFieldHelper),
                    const SizedBox(height: AppSpacing.xxs),
                    SelectableText(
                      field.value,
                      style: AppTypography.formFieldValue,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
