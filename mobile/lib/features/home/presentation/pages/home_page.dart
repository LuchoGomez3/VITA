import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

/// Pagina de inicio de la app.
class HomePage extends StatelessWidget {
  /// Crea una nueva pagina de inicio.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trazabilidad ganadera'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base inicial del front',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'La app queda lista para crecer por modulos, con navegacion y una feature real como referencia.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrar animal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Primer modulo con capas presentation, domain y data.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFilledButton(
                    label: 'Abrir modulo',
                    onPressed: () => context.go(AppRoutes.animalRegisterStep1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalle de animal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Ejemplo de navegación a una feature separada usando un id en la ruta.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFilledButton(
                    label: 'Ver animal A-001',
                    onPressed: () => context.go(
                      AppRoutes.animalDetailById('A-001'),
                    ),
                  ),
                ],
              ),
            ),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporte de SENASA',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Generación offline de planillas de movimientos y existencias en formato TXT y CSV.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFilledButton(
                    label: 'Ver reporte de SENASA',
                    onPressed: () => context.go(
                      AppRoutes.senasaReport,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
