import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/livestock_sale_success_view.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_animal_selection_step.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_operation_step.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_review_step.dart';
import 'package:go_router/go_router.dart';

/// Factory del BLoC cuya vida pertenece a la pagina raiz del flujo.
typedef LivestockSaleBlocFactory = LivestockSaleBloc Function({required String establishmentId});

/// Mantiene una unica instancia del BLoC durante los tres pasos de la venta.
class LivestockSaleFlowPage extends StatelessWidget {
  /// Crea el flujo para el establecimiento seleccionado.
  const LivestockSaleFlowPage({
    required this.establishmentId,
    required this.createBloc,
    super.key,
  });

  /// Establecimiento al que pertenecen venta y animales.
  final String establishmentId;

  /// Construye el BLoC con dependencias resueltas por composition.
  final LivestockSaleBlocFactory createBloc;

  @override
  Widget build(BuildContext context) {
    // El provider se ubica sobre los tres pasos para conservar un solo borrador
    // y cerrar automaticamente el BLoC cuando termina el flujo.
    return BlocProvider(
      create: (_) => createBloc(establishmentId: establishmentId),
      child: const _LivestockSaleFlowView(),
    );
  }
}

class _LivestockSaleFlowView extends StatelessWidget {
  const _LivestockSaleFlowView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LivestockSaleBloc, LivestockSaleState>(
      // Solo los cambios que pueden producir feedback disparan el listener;
      // las ediciones ordinarias del formulario no repiten SnackBars.
      listenWhen: (previous, current) {
        return previous.stepError != current.stepError ||
            previous.animalSelectionResult != current.animalSelectionResult ||
            previous.submitResult != current.submitResult;
      },
      listener: _showError,
      child: BlocBuilder<LivestockSaleBloc, LivestockSaleState>(
        builder: (context, state) {
          // Una escritura local exitosa reemplaza el wizard completo. Asi no se
          // puede confirmar accidentalmente dos veces el mismo borrador.
          if (state.submitResult case Data<LivestockSale>(:final data)) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) context.go(AppRoutes.home);
              },
              child: Scaffold(
                body: LivestockSaleSuccessView(
                  sale: data,
                  onRegisterAnotherSale: () => _startAnotherSale(
                    context,
                    state.form.establishmentId,
                  ),
                  onBackHome: () => context.go(AppRoutes.home),
                ),
              ),
            );
          }

          return PopScope(
            canPop: state.currentStep == LivestockSaleStep.animals,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.read<LivestockSaleBloc>().add(
                  const LivestockSaleEvent.previousStepRequested(),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => _goBack(context, state.currentStep),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: _FlowTitle(step: state.currentStep),
              ),
              body: Column(
                children: [
                  _FlowProgress(currentStep: state.currentStep),
                  Expanded(
                    // IndexedStack conserva el estado visual de cada paso. Al
                    // volver, controladores y posicion interna siguen montados.
                    child: IndexedStack(
                      index: state.currentStep.index,
                      children: [
                        LivestockSaleAnimalSelectionStep(
                          onRfidScanRequested: () => context.push<String>(
                            AppRoutes.rfidScanForLivestockSale(
                              state.form.establishmentId,
                            ),
                          ),
                        ),
                        const LivestockSaleOperationStep(),
                        const LivestockSaleReviewStep(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _FlowNavigation(
                step: state.currentStep,
                isSubmitting: state.submitResult is Loading<LivestockSale>,
                canContinue: state.currentStep != LivestockSaleStep.animals || state.selection.animals.isNotEmpty,
                onBack: () => _goBack(context, state.currentStep),
                onNext: () => _goNext(context, state.currentStep),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showError(BuildContext context, LivestockSaleState state) {
    // Los errores de paso tienen prioridad sobre los resultados asincronos de
    // seleccion y persistencia para mostrar el problema mas inmediato.
    final error =
        state.stepError ??
        switch (state.animalSelectionResult) {
          ResultError(:final error) => error,
          _ => switch (state.submitResult) {
            ResultError(:final error) => error,
            _ => null,
          },
        };
    if (error == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message)));
  }

  void _goBack(BuildContext context, LivestockSaleStep step) {
    // Dentro del wizard se retrocede por estado; solo el primer paso abandona
    // la feature y vuelve a la ruta anterior o al inicio.
    if (step != LivestockSaleStep.animals) {
      context.read<LivestockSaleBloc>().add(
        const LivestockSaleEvent.previousStepRequested(),
      );
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _goNext(BuildContext context, LivestockSaleStep step) {
    context.read<LivestockSaleBloc>().add(
      step == LivestockSaleStep.review
          ? const LivestockSaleEvent.submitRequested()
          : const LivestockSaleEvent.nextStepRequested(),
    );
  }

  void _startAnotherSale(BuildContext context, String establishmentId) {
    // Salir de la ruta actual destruye el BLoC confirmado. La nueva ruta crea
    // otro borrador limpio, pero conserva el establecimiento seleccionado.
    GoRouter.of(context)
      ..go(AppRoutes.home)
      ..push(AppRoutes.livestockSaleForEstablishment(establishmentId));
  }
}

class _FlowProgress extends StatelessWidget {
  const _FlowProgress({required this.currentStep});

  final LivestockSaleStep currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (var index = 0; index < LivestockSaleStep.values.length; index++) ...[
            Expanded(
              child: Container(
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: index <= currentStep.index ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            if (index < LivestockSaleStep.values.length - 1) const SizedBox(width: AppSpacing.xxs),
          ],
        ],
      ),
    );
  }
}

class _FlowTitle extends StatelessWidget {
  const _FlowTitle({required this.step});

  final LivestockSaleStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          LivestockSaleStrings.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          switch (step) {
            LivestockSaleStep.animals => LivestockSaleStrings.animalSelectionStep,
            LivestockSaleStep.operation => LivestockSaleStrings.operationDataStep,
            LivestockSaleStep.review => LivestockSaleStrings.reviewStep,
          },
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _FlowNavigation extends StatelessWidget {
  const _FlowNavigation({
    required this.step,
    required this.isSubmitting,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
  });

  final LivestockSaleStep step;
  final bool isSubmitting;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              label: LivestockSaleStrings.back,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: AppFilledButton(
              label: step == LivestockSaleStep.review ? LivestockSaleStrings.confirmSale : LivestockSaleStrings.next,
              icon: Icon(
                step == LivestockSaleStep.review ? Icons.check : Icons.arrow_forward,
              ),
              onPressed: isSubmitting || !canContinue ? null : onNext,
            ),
          ),
        ],
      ),
    );
  }
}
