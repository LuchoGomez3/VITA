import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step1_filters.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step2_validation.dart';
import 'package:go_router/go_router.dart';

/// Factory que construye el Cubit del formulario SENASA.
typedef SenasaReportCubitFactory = SenasaReportCubit Function();

/// SENASA report flow connected to the backend.
class SenasaReportPage extends StatelessWidget {
  /// Creates the report page with its state factory.
  const SenasaReportPage({
    required this.createCubit,
    super.key,
  });

  /// Construye el Cubit cuyo ciclo de vida pertenece a esta página.
  final SenasaReportCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..loadEstablishments(),
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
  final _fileNameController = TextEditingController();

  // El formulario permanece montado mientras una operación remota falla, por
  // lo que un corte de conexión no borra el establecimiento, período o nombre.
  int _currentStep = 1;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String? _selectedOrigin;

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SenasaReportCubit, SenasaReportState>(
      builder: (context, state) => Scaffold(
        appBar: AppBarHeader(
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
                totalSteps: 2,
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
    return SenasaStrings.step2Title;
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
            startDate: _startDate,
            endDate: _endDate,
            onDatesChanged: (start, end) => setState(() {
              _startDate = start;
              _endDate = end;
            }),
            selectedOrigin: _selectedOrigin,
            onOriginChanged: (value) => setState(() => _selectedOrigin = value),
            fileNameController: _fileNameController,
          ),
        );
      case 2:
        return ReportStep2Validation(
          key: const ValueKey('Step2'),
          startDate: _startDate,
          endDate: _endDate,
          validation: state.validation,
          onRetry: _validateSelectedRecords,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButton(SenasaReportState state) {
    var label = SenasaStrings.btnContinue;
    if (_currentStep == 2) label = SenasaStrings.btnGenerate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.iconButtonBackground,
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: AppFilledButton(
          label: label,
          icon: Icon(_currentStep == 2 ? Icons.download : Icons.arrow_forward),
          onPressed: _canContinue(state) ? _handleBottomButtonPressed : null,
        ),
      ),
    );
  }

  void _handleBottomButtonPressed() {
    if (_currentStep == 1 && !(_stepOneFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_currentStep == 1) {
      setState(() => _currentStep++);
      _validateSelectedRecords();
      return;
    }

    final validation = context.read<SenasaReportCubit>().state.validation;
    if (_selectedOrigin != null && validation is Data<SenasaValidationResult>) {
      context.push(
        AppRoutes.senasaReportGeneration,
        extra: SenasaReportRequest(
          establishmentId: _selectedOrigin!,
          from: DateTime(_startDate.year, _startDate.month, _startDate.day),
          to: DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
          fileName: _fileNameController.text.trim(),
          animalCount: validation.data.exportableAnimals,
        ),
      );
    }
  }

  bool _canContinue(SenasaReportState state) {
    if (_currentStep == 1) {
      return state.establishments is Data<List<SenasaEstablishment>>;
    }
    if (_currentStep == 2) {
      final validation = state.validation;
      return validation is Data<SenasaValidationResult> && validation.data.issues.isEmpty;
    }
    return true;
  }

  void _validateSelectedRecords() {
    final establishmentId = _selectedOrigin;
    if (establishmentId == null) {
      return;
    }
    context.read<SenasaReportCubit>().validateRecords(
      SenasaReportValidationRequest(
        establishmentId: establishmentId,
        from: DateTime(_startDate.year, _startDate.month, _startDate.day),
        to: DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
        fileName: _fileNameController.text.trim(),
      ),
    );
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
