import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AnimalDetailPage extends StatelessWidget {
  const AnimalDetailPage({
    required this.animalId,
    super.key,
  });

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