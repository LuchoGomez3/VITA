import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:go_router/go_router.dart';

/// Lee la genealogía del animal [animalId].
typedef LoadAnimalGenealogy = Future<Result<AnimalGenealogy>> Function(String animalId);

/// Pestaña Genealogía (diseño "Ficha · Genealogía"): el animal, sus padres y
/// sus abuelos, y debajo sus crías. Tocar un nodo abre la ficha de ese animal.
///
/// Se arma con los animales guardados en el celular, así funciona sin señal.
class AnimalGenealogyTab extends StatefulWidget {
  /// Crea la pestaña para [animal].
  const AnimalGenealogyTab({required this.animal, required this.loadGenealogy, super.key});

  /// Animal de la ficha.
  final AnimalDetail animal;

  /// Lee padres, abuelos y crías.
  final LoadAnimalGenealogy loadGenealogy;

  @override
  State<AnimalGenealogyTab> createState() => _AnimalGenealogyTabState();
}

class _AnimalGenealogyTabState extends State<AnimalGenealogyTab> {
  late Future<Result<AnimalGenealogy>> _genealogy = widget.loadGenealogy(widget.animal.id);

  @override
  void didUpdateWidget(AnimalGenealogyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // La ficha recarga el animal (p. ej. al volver de un pesaje): se relee por
    // si cambió algún dato de la genealogía.
    if (oldWidget.animal != widget.animal) {
      _genealogy = widget.loadGenealogy(widget.animal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<AnimalGenealogy>>(
      future: _genealogy,
      builder: (context, snapshot) {
        final result = snapshot.data;
        return switch (result) {
          null => const Center(child: CircularProgressIndicator()),
          Success<AnimalGenealogy>(:final data) => _GenealogyTree(animal: widget.animal, genealogy: data),
          Failure<AnimalGenealogy>(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(error.message, textAlign: TextAlign.center),
            ),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _GenealogyTree extends StatelessWidget {
  const _GenealogyTree({required this.animal, required this.genealogy});

  final AnimalDetail animal;
  final AnimalGenealogy genealogy;

  @override
  Widget build(BuildContext context) {
    final hasParents = genealogy.father != null || genealogy.mother != null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const AnimalFichaSectionTitle(AnimalDetailStrings.genealogyTreeTitle),
        const SizedBox(height: AppSpacing.sm),
        _GenealogyNode(
          visualTag: animal.visualTag,
          label: AnimalDetailStrings.genealogyCurrent(animal.breed),
          isCurrent: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
        const AnimalFichaSectionTitle(AnimalDetailStrings.genealogyParentsSection),
        const SizedBox(height: AppSpacing.xs),
        _NodePair(
          left: (AnimalDetailStrings.genealogyFather, genealogy.father, AppColors.earTagCeleste),
          right: (AnimalDetailStrings.genealogyMother, genealogy.mother, AppColors.earTagYellow),
        ),
        const SizedBox(height: AppSpacing.md),
        const AnimalFichaSectionTitle(AnimalDetailStrings.genealogyGrandparentsSection),
        const SizedBox(height: AppSpacing.xs),
        _NodePair(
          left: (
            AnimalDetailStrings.genealogyPaternalGrandfather,
            genealogy.paternalGrandfather,
            AppColors.earTagCeleste,
          ),
          right: (
            AnimalDetailStrings.genealogyPaternalGrandmother,
            genealogy.paternalGrandmother,
            AppColors.earTagYellow,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _NodePair(
          left: (
            AnimalDetailStrings.genealogyMaternalGrandfather,
            genealogy.maternalGrandfather,
            AppColors.earTagCeleste,
          ),
          right: (
            AnimalDetailStrings.genealogyMaternalGrandmother,
            genealogy.maternalGrandmother,
            AppColors.earTagYellow,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Hint(text: hasParents ? AnimalDetailStrings.genealogyTapHint : AnimalDetailStrings.genealogyEmpty),
        if (genealogy.offspring.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AnimalFichaSectionTitle(AnimalDetailStrings.genealogyOffspringSection(genealogy.offspring.length)),
          const SizedBox(height: AppSpacing.xs),
          for (final child in genealogy.offspring) ...[
            _GenealogyNode(
              visualTag: child.visualTag,
              label: AnimalDetailStrings.genealogyNode(child.categoryName, child.breed),
              onTap: () => _open(context, child),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ],
    );
  }
}

void _open(BuildContext context, GenealogyAnimal animal) {
  context.push(AppRoutes.animalDetailById(animal.id));
}

/// Dos nodos lado a lado (padre y madre, o abuelo y abuela).
class _NodePair extends StatelessWidget {
  const _NodePair({required this.left, required this.right});

  final (String, GenealogyAnimal?, Color) left;
  final (String, GenealogyAnimal?, Color) right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _relativeNode(context, left)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: _relativeNode(context, right)),
        ],
      ),
    );
  }

  Widget _relativeNode(BuildContext context, (String, GenealogyAnimal?, Color) entry) {
    final (role, animal, color) = entry;
    if (animal == null) {
      return _GenealogyNode(label: AnimalDetailStrings.genealogyMissing(role), isMissing: true);
    }
    return _GenealogyNode(
      visualTag: animal.visualTag,
      tagColor: color,
      label: AnimalDetailStrings.genealogyNode(role, animal.breed),
      onTap: () => _open(context, animal),
    );
  }
}

/// Nodo del árbol (diseño `GeneNode`): caravana y etiqueta.
class _GenealogyNode extends StatelessWidget {
  const _GenealogyNode({
    required this.label,
    this.visualTag,
    this.tagColor = AppColors.earTagYellow,
    this.isCurrent = false,
    this.isMissing = false,
    this.onTap,
  });

  final String label;
  final String? visualTag;
  final Color tagColor;
  final bool isCurrent;
  final bool isMissing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tag = visualTag;
    return Opacity(
      opacity: isMissing ? 0.55 : 1,
      child: Material(
        color: isCurrent ? AppColors.backgroundSecondary : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: isCurrent ? BorderSide.none : const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                if (tag == null || isMissing) const _MissingTag() else AppEarTagBadge(visualTag: tag, color: tagColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lugar de la caravana cuando falta el dato (borde punteado del diseño).
class _MissingTag extends StatelessWidget {
  const _MissingTag();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: const SizedBox(width: 38, height: 28),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.sm)));
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 7) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(text, style: AppTypography.formFieldHelper.copyWith(color: AppColors.textSecondary)),
    );
  }
}
