import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/campaign_progress_card.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/health_alert_tile.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/health_tab_selector.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/scheduled_vaccination_row.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/treatment_card.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de Sanidad: bandeja de campañas de vacunación, tratamientos con
/// período de carencia y alertas, como 3 tabs de una sola página.
///
/// Réplica visual estática del diseño `SanidadTabs` (ver
/// `.claude/specs/sanidad.md`); no hay módulo `eventos_sanitarios` en backend
/// todavía, ni validación real de carencia.
class HealthPage extends StatefulWidget {
  /// Crea la pantalla de sanidad.
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  HealthTab _tab = HealthTab.vaccinations;

  void _showOutOfScopeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fuera de alcance de esta iniciativa')),
    );
  }

  void _openApplyVaccination() => context.push(AppRoutes.applyVaccination);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: HealthStrings.title,
        headline: HealthStrings.establishmentTitle,
        actions: [AppSyncBadge(pendingCount: healthPendingSyncCount)],
      ),
      floatingActionButton: _tab == HealthTab.vaccinations
          ? FloatingActionButton.extended(
              onPressed: _openApplyVaccination,
              label: const Text(HealthStrings.applyFab),
              icon: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: HealthTabSelector(activeTab: _tab, onChanged: (tab) => setState(() => _tab = tab)),
            ),
            Expanded(
              child: switch (_tab) {
                HealthTab.vaccinations => _VaccinationsTab(
                  onApplyCampaign: _openApplyVaccination,
                ),
                HealthTab.treatments => const _TreatmentsTab(),
                HealthTab.alerts => _AlertsTab(
                  onApplyAlert: _openApplyVaccination,
                  onOtherAction: _showOutOfScopeSnackBar,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccinationsTab extends StatelessWidget {
  const _VaccinationsTab({required this.onApplyCampaign});

  final VoidCallback onApplyCampaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl * 2),
      children: [
        Text(
          HealthStrings.activeCampaignsTitle(healthCampaignsMock.length),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final campaign in healthCampaignsMock) ...[
          CampaignProgressCard(campaign: campaign, onApply: onApplyCampaign),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(HealthStrings.scheduledSectionTitle, style: Theme.of(context).textTheme.titleLarge),
        AppSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              for (final scheduled in healthScheduledMock) ScheduledVaccinationRow(scheduled: scheduled),
            ],
          ),
        ),
      ],
    );
  }
}

class _TreatmentsTab extends StatelessWidget {
  const _TreatmentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl * 2),
      children: [
        Text(
          HealthStrings.treatmentsInProgressTitle(healthTreatmentsInProgressMock.length),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final treatment in healthTreatmentsInProgressMock) ...[
          TreatmentCard(treatment: treatment),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(HealthStrings.treatmentHistoryTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppTimeline(
          items: [
            for (final entry in healthTreatmentHistoryMock)
              AppTimelineItem(
                date: entry.date,
                title: entry.title,
                description: '${entry.animalCount} ${HealthStrings.animalCountSuffix}',
                icon: Icons.medical_services_outlined,
                iconColor: AppColors.primary,
              ),
          ],
        ),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab({required this.onApplyAlert, required this.onOtherAction});

  final VoidCallback onApplyAlert;
  final VoidCallback onOtherAction;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl * 2),
      itemCount: healthAlertsMock.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final alert = healthAlertsMock[index];
        final isApplyAlert = alert.actionLabel == HealthStrings.applyLink;
        return HealthAlertTile(alert: alert, onAction: isApplyAlert ? onApplyAlert : onOtherAction);
      },
    );
  }
}
