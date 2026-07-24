import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step1_filters.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step2_validation.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step3_format.dart';
import 'package:go_router/go_router.dart';

/// SENASA report flow connected to the backend.
class SenasaReportPage extends StatelessWidget {
  /// Creates the report page with its domain use cases.
  const SenasaReportPage({
    required this.getEstablishments,
    required this.generateReport,
    super.key,
  });

  /// Loads establishments available to the authenticated user.
  final GetSenasaEstablishmentsUseCase getEstablishments;

  /// Generates the selected report file.
  final GenerateSenasaReportUseCase generateReport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SenasaReportCubit(
        getEstablishments: getEstablishments,
        generateReport: generateReport,
      )..loadEstablishments(),
      child: const _SenasaReportView(),
    );
  }
}

class _SenasaReportView extends StatefulWidget {
  const _SenasaReportView();

  @override
  State<_SenasaReportView> createState() => _SenasaReportViewState();
}

class _SenasaReportViewState extends State<_SenasaReportView> {
  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepThreeFormKey = GlobalKey<FormState>();
  final _responsibleNameController = TextEditingController();
  final _responsibleDniController = TextEditingController();

  // GESTIÓN DEL FLUJO ÚNICO
  int _currentStep = 1; // 1: Parámetros, 2: Validación y Formato

  // ESTADOS DEL PASO 1 (Datos)
  String _selectedMovement = 'Ingreso';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String? _selectedOrigin;

  // ESTADOS DEL PASO 2 (Exportación)
  String _selectedFormat = 'PDF';

  @override
  void dispose() {
    _responsibleNameController.dispose();
    _responsibleDniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SenasaReportCubit, SenasaReportState>(
      builder: (context, state) => Scaffold(
        appBar: AppHeader(
          title: SenasaStrings.pageTitle,
          onBackPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              StepProgressBar(
                currentStep: _currentStep,
                totalSteps: 3,
                stepTitle: _getStepTitle(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStepView(state),
                ),
              ),
              _buildBottomButton(state),
            ],
          ),
        ),
      ),
    );
  }

  // Retorna el título dinámico del Header
  String _getStepTitle() {
    if (_currentStep == 1) return SenasaStrings.step1Title;
    if (_currentStep == 2) return SenasaStrings.step2Title;
    return SenasaStrings.step3Title;
  }

  // Selecciona el widget modular del cuerpo
  Widget _buildCurrentStepView(SenasaReportState state) {
    switch (_currentStep) {
      case 1:
        return state.establishments.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => _EstablishmentsError(
            message: error.message,
            onRetry: context.read<SenasaReportCubit>().loadEstablishments,
          ),
          data: (establishments) => ReportStep1Filters(
            key: const ValueKey('Step1'),
            establishments: establishments,
            formKey: _stepOneFormKey,
            selectedMovement: _selectedMovement,
            onMovementChanged: (val) => setState(() => _selectedMovement = val),
            startDate: _startDate,
            endDate: _endDate,
            onDatesChanged: (start, end) => setState(() {
              _startDate = start;
              _endDate = end;
            }),
            selectedOrigin: _selectedOrigin,
            onOriginChanged: (value) => setState(() => _selectedOrigin = value),
          ),
        );
      case 2:
        return ReportStep2Validation(
          key: const ValueKey('Step2'),
          selectedMovement: _selectedMovement,
          startDate: _startDate,
          endDate: _endDate,
        );
      case 3:
        return ReportStep3Format(
          key: const ValueKey('Step3'),
          formKey: _stepThreeFormKey,
          selectedFormat: _selectedFormat,
          onFormatChanged: (val) => setState(() => _selectedFormat = val),
          responsibleNameController: _responsibleNameController,
          responsibleDniController: _responsibleDniController,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButton(SenasaReportState state) {
    var label = SenasaStrings.btnContinue;
    if (_currentStep == 2) label = SenasaStrings.btnNext;
    if (_currentStep == 3) label = SenasaStrings.btnGenerate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: AppFilledButton(
          label: label,
          icon: Icon(_currentStep == 3 ? Icons.download : Icons.arrow_forward),
          onPressed: _currentStep == 1 && state.establishments is! Data<List<SenasaEstablishment>>
              ? null
              : _handleBottomButtonPressed,
        ),
      ),
    );
  }

  void _handleBottomButtonPressed() {
    if (_currentStep == 1 && !(_stepOneFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    final isValid = _stepThreeFormKey.currentState?.validate() ?? false;
    if (isValid && _selectedOrigin != null) {
      context.push(
        AppRoutes.senasaReportGeneration,
        extra: SenasaReportRequest(
          establishmentId: _selectedOrigin!,
          format: _selectedFormat.toLowerCase(),
          from: DateTime(_startDate.year, _startDate.month, _startDate.day),
          to: DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
          eventType: SenasaStrings.eventTypeApiValues[_selectedMovement] ?? _selectedMovement.toLowerCase(),
          responsibleName: _responsibleNameController.text.trim(),
          responsibleDni: _responsibleDniController.text.trim(),
        ),
      );
    }
  }
}

class _EstablishmentsError extends StatelessWidget {
  const _EstablishmentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: SenasaStrings.retry,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
