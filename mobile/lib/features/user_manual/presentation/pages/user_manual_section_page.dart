import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/strings/user_manual_strings.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/widgets/manual_markdown_view.dart';

/// Detalle de una sección del manual.
class UserManualSectionPage extends StatelessWidget {
  /// Crea la pantalla de [section].
  const UserManualSectionPage({required this.section, super.key});

  /// Sección a mostrar.
  final ManualSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        centerTitle: true,
        title: const Text(UserManualStrings.title, style: AppTypography.appBarTitle),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            Semantics(
              header: true,
              child: Text(section.title, style: AppTypography.bigTitle),
            ),
            if (!section.isGeneral) ...[
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: AppStatusChip(label: UserManualStrings.appliesTo(section.roles)),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ManualMarkdownView(blocks: section.blocks),
          ],
        ),
      ),
    );
  }
}
