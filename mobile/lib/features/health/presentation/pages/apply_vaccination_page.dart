import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/withdrawal_callout.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de Aplicar vacunación: caravanas seleccionadas, datos del
/// producto y callout de carencia.
///
/// Réplica visual estática del diseño `AplicarVacunacion` (ver
/// `.claude/specs/sanidad.md`); las caravanas, el producto y la carencia son
/// mock fijo, sin validaciones ni persistencia real.
class ApplyVaccinationPage extends StatefulWidget {
  /// Crea la pantalla de aplicar vacunación.
  const ApplyVaccinationPage({super.key});

  @override
  State<ApplyVaccinationPage> createState() => _ApplyVaccinationPageState();
}

class _ApplyVaccinationPageState extends State<ApplyVaccinationPage> {
  List<ApplyVaccinationEarTagMock> _selectedEarTags = applyVaccinationEarTagsMock;
  String _product = applyVaccinationProductMock;
  final _batchController = TextEditingController(text: applyVaccinationBatchMock);
  final _doseController = TextEditingController(text: applyVaccinationDoseMlMock);
  DateTime _applicationDate = applyVaccinationDateMock;

  @override
  void dispose() {
    _batchController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _showOutOfScopeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fuera de alcance de esta iniciativa')),
    );
  }

  void _handleRegisterApplication() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(HealthStrings.applicationRegisteredToast)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ApplyVaccinationHeader(onClose: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        HealthStrings.selectedAnimalsTitle(_selectedEarTags.length),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedEarTags = const []),
                        child: Text(
                          HealthStrings.clearSelectionLink,
                          style: AppTypography.inlinePrimaryLink.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final earTag in _selectedEarTags)
                        AppEarTagBadge(visualTag: earTag.visualTag, color: earTag.color, width: 64),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppOutlinedButton(
                    label: HealthStrings.readAnotherTagButton,
                    icon: const Icon(Icons.bluetooth),
                    onPressed: _showOutOfScopeSnackBar,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(HealthStrings.productSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  AppDropdownFormField<String>(
                    title: HealthStrings.productFieldLabel,
                    hintText: HealthStrings.productFieldLabel,
                    initialValue: _product,
                    options: [AppDropdownOption(value: _product, label: _product)],
                    onChanged: (value) => setState(() => _product = value ?? _product),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextFormField(
                    title: HealthStrings.batchFieldLabel,
                    hintText: HealthStrings.batchFieldLabel,
                    controller: _batchController,
                    style: AppTypography.monoValue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextFormField(
                    title: HealthStrings.doseFieldLabel,
                    hintText: HealthStrings.doseFieldLabel,
                    controller: _doseController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDateFormField(
                    title: HealthStrings.applicationDateFieldLabel,
                    hintText: HealthStrings.applicationDateFieldLabel,
                    value: _applicationDate,
                    onChanged: (date) => setState(() => _applicationDate = date),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  WithdrawalCallout(
                    message: HealthStrings.withdrawalCallout(
                      applyVaccinationWithdrawalDays,
                      applyVaccinationWithdrawalMessage,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppFilledButton(
                label: HealthStrings.registerApplicationCta,
                onPressed: _handleRegisterApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyVaccinationHeader extends StatelessWidget {
  const _ApplyVaccinationHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: HealthStrings.applyVaccinationCloseTooltip,
            onPressed: onClose,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(HealthStrings.applyVaccinationTitle, style: AppTypography.appBarTitle),
                Text(applyVaccinationCampaignSubtitle, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
