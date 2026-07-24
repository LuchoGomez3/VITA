import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Page that shows the detail for a registered animal.
class AnimalDetailPage extends StatelessWidget {
  /// Creates the animal detail page for [animalId].
  const AnimalDetailPage({
    required this.animalId,
    super.key,
  });

  /// Animal identifier used by the detail page.
  final String animalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de animal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Animal registrado',
                subtitle:
                    'Base inicial de la pantalla de detalle. Después puede crecer con su propio Cubit y acciones específicas.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Nro caravana',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                animalId,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
