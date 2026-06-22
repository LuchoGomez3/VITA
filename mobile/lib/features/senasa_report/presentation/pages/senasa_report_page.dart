import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step1_filters.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step2_validation.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step3_format.dart';
import 'package:go_router/go_router.dart';

class SenasaReportPage extends StatefulWidget {
  const SenasaReportPage({super.key});

  @override
  State<SenasaReportPage> createState() => _SenasaReportPageState();
}

class _SenasaReportPageState extends State<SenasaReportPage> {
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
    return Scaffold(
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
                child: _buildCurrentStepView(), // Inyecta el widget correspondiente
              ),
            ),
            _buildBottomButton(),
          ],
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
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return ReportStep1Filters(
          key: const ValueKey('Step1'),
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

  Widget _buildBottomButton() {
    String label = SenasaStrings.btnContinue;
    if (_currentStep == 2) label = SenasaStrings.btnNext;
    if (_currentStep == 3) label = SenasaStrings.btnGenerate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
          onPressed: _handleBottomButtonPressed,
        ),
      ),
    );
  }

  void _handleBottomButtonPressed() {
    if (_currentStep == 1 &&
        !(_stepOneFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    final isValid = _stepThreeFormKey.currentState?.validate() ?? false;
    if (isValid) {
      context.push(AppRoutes.senasaReportGeneration);
    }
  }
}
