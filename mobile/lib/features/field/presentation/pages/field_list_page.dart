import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_paddock_card.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_view_toggle.dart';
import 'package:go_router/go_router.dart';

/// Lista escaneable de potreros, alternativa al mapa.
class FieldListPage extends StatelessWidget {
  /// Crea la pantalla de lista de potreros.
  const FieldListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: FieldStrings.title,
        headline: FieldStrings.establishmentTitle,
        actions: [AppSyncBadge(pendingCount: FieldStrings.pendingSyncCount)],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            AppStatusChip(
                              label: FieldStrings.paddockCountChip(paddocksTotalCount),
                              tone: AppStatusChipTone.success,
                              showDot: true,
                            ),
                            AppStatusChip(
                              label: FieldStrings.totalHectaresChip(
                                paddocksTotalHectares.toStringAsFixed(0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.filter_list, color: AppColors.textHint),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xl * 2,
                    ),
                    itemCount: paddocksMock.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final paddock = paddocksMock[index];
                      return FieldPaddockCard(
                        paddock: paddock,
                        onTap: () => context.push(AppRoutes.fieldDetailById(paddock.id)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Center(child: FieldViewToggle(isMapActive: false)),
            ),
          ],
        ),
      ),
    );
  }
}
