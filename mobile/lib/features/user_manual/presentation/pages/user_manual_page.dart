import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/cubit/user_manual_cubit.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/strings/user_manual_strings.dart';
import 'package:go_router/go_router.dart';

/// Abre el detalle de [section]; por defecto navega a su ruta.
typedef OpenManualSection = void Function(BuildContext context, ManualSection section);

/// Índice del manual: las secciones que la persona puede usar según su rol.
class UserManualPage extends StatelessWidget {
  /// Crea la pantalla.
  const UserManualPage({required this.createCubit, this.onOpenSection, super.key});

  /// Construye el Cubit (inyectado para los tests).
  final UserManualCubit Function() createCubit;

  /// Reemplaza la navegación al detalle (para los tests).
  final OpenManualSection? onOpenSection;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          centerTitle: true,
          title: const Text(UserManualStrings.title, style: AppTypography.appBarTitle),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<UserManualCubit, ResultState<UserManual>>(
            builder: (context, state) => switch (state) {
              Data<UserManual>(:final data) => _Index(manual: data, onOpen: onOpenSection ?? _openSection),
              ResultError<UserManual>() => _LoadError(onRetry: context.read<UserManualCubit>().load),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  static void _openSection(BuildContext context, ManualSection section) {
    context.push(AppRoutes.userManualSection, extra: section);
  }
}

class _Index extends StatelessWidget {
  const _Index({required this.manual, required this.onOpen});

  final UserManual manual;
  final OpenManualSection onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(UserManualStrings.rolesHint(manual.userRoles), style: AppTypography.pageBodyTitle),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 16, color: AppColors.textHint),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Text(
                UserManualStrings.offlineHint,
                style: AppTypography.formFieldHelper.copyWith(color: AppColors.textHint),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (manual.sections.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: Text(UserManualStrings.empty, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
          ),
        for (final section in manual.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SectionCard(section: section, onTap: () => onOpen(context, section)),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.onTap});

  final ManualSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: AppTypography.formFieldValueEmphasis),
                    if (section.summary.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(section.summary, style: AppTypography.formFieldHelper),
                    ],
                    if (!section.isGeneral) ...[
                      const SizedBox(height: AppSpacing.xs),
                      AppStatusChip(label: UserManualStrings.appliesTo(section.roles)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(UserManualStrings.loadError, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text(UserManualStrings.retry)),
          ],
        ),
      ),
    );
  }
}
