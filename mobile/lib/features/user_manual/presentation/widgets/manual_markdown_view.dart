import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';

/// Dibuja los bloques de una sección con el tema de la app.
class ManualMarkdownView extends StatelessWidget {
  /// Crea la vista de [blocks].
  const ManualMarkdownView({required this.blocks, super.key});

  /// Contenido ya interpretado por el parser.
  final List<ManualBlock> blocks;

  /// Texto corrido: el de los campos de formulario, con más interlineado.
  static final TextStyle _body = AppTypography.formFieldValue.copyWith(height: 1.4);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, block) in blocks.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : _gapBefore(block)),
            child: _block(block),
          ),
      ],
    );
  }

  static double _gapBefore(ManualBlock block) => block is ManualHeading ? AppSpacing.lg : AppSpacing.sm;

  Widget _block(ManualBlock block) => switch (block) {
    ManualHeading(:final level, :final spans) => Semantics(
      header: true,
      child: Text.rich(_spans(spans), style: _headingStyle(level)),
    ),
    ManualParagraph(:final spans) => Text.rich(_spans(spans), style: _body),
    ManualList() => _ManualListView(list: block, style: _body),
    ManualNote(:final spans) => _ManualNoteView(text: _spans(spans)),
  };

  static TextStyle _headingStyle(int level) => switch (level) {
    1 => AppTypography.appBarTitle,
    2 => AppTypography.pageTitle.copyWith(fontSize: 18, color: AppColors.textEmphasis),
    _ => AppTypography.secondaryEmphasis,
  };
}

/// Convierte tramos en un [TextSpan] con la negrita aplicada.
TextSpan _spans(List<ManualSpan> spans) => TextSpan(
  children: [
    for (final span in spans)
      TextSpan(
        text: span.text,
        style: span.isBold ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
  ],
);

class _ManualListView extends StatelessWidget {
  const _ManualListView({required this.list, required this.style});

  final ManualList list;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in list.items.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpacing.lg,
                  child: Text(
                    list.isOrdered ? '${list.start + index}.' : '•',
                    style: style.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                Expanded(child: Text.rich(_spans(item), style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ManualNoteView extends StatelessWidget {
  const _ManualNoteView({required this.text});

  final TextSpan text;

  @override
  Widget build(BuildContext context) {
    // Un borde de un solo lado no admite borderRadius: se recorta afuera.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondaryLight,
          border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text.rich(text, style: ManualMarkdownView._body.copyWith(color: AppColors.positiveText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
