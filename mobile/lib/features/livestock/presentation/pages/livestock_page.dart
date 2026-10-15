import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:go_router/go_router.dart';

/// Organiza la lectura de caravanas y la consulta territorial de la hacienda.
class LivestockPage extends StatelessWidget {
  /// Recibe la apertura del lector desde la composición de rutas.
  const LivestockPage({required this.onIdentifyAnimal, super.key});

  /// Resuelve el establecimiento antes de abrir el mismo lector que Inicio.
  final VoidCallback onIdentifyAnimal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: LivestockStrings.title),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          // Iguala los márgenes de Inicio y desplaza el espacio seguro con
          // el contenido para conservar la separación final con la barra.
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadingCard(onPressed: onIdentifyAnimal),
              const SizedBox(height: AppSpacing.sm),
              _ManagementCard(
                title: LivestockStrings.fieldTitle,
                description: LivestockStrings.fieldDescription,
                icon: Icons.map_outlined,
                onTap: () => context.push(AppRoutes.field),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destaca la identificación como punto de entrada al trabajo con animales.
class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      color: AppColors.backgroundSecondaryLight,
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: AppSpacing.xl,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.bluetooth_searching, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(LivestockStrings.readTagTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          const Text(LivestockStrings.readTagDescription),
          const SizedBox(height: AppSpacing.lg),
          AppFilledButton(
            label: LivestockStrings.readTagTitle,
            icon: const Icon(Icons.bluetooth),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

/// Presenta un acceso secundario disponible dentro de Hacienda.
class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  /// Nombre del módulo dentro de Hacienda.
  final String title;

  /// Resumen del destino disponible.
  final String description;

  /// Identificación visual del tipo de gestión.
  final IconData icon;

  /// Abre el módulo seleccionado.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.backgroundTertiary,
                child: Icon(icon, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
