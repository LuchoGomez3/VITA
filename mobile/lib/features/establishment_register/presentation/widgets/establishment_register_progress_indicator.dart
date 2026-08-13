import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Barra de progreso compartida por los pasos del alta de establecimiento.
class EstablishmentRegisterProgressIndicator extends StatelessWidget {
  /// Crea una barra de progreso para el paso actual del flujo.
  const EstablishmentRegisterProgressIndicator({
    required this.currentStep,
    super.key,
    this.totalSteps = 4,
  }) : assert(currentStep > 0, 'currentStep debe ser mayor que cero.'),
       assert(totalSteps > 0, 'totalSteps debe ser mayor que cero.'),
       assert(
         currentStep <= totalSteps,
         'currentStep no puede superar totalSteps.',
       );

  /// Numero del paso que se esta mostrando.
  final int currentStep;

  /// Cantidad total de pasos del flujo.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: currentStep / totalSteps,
      minHeight: 4,
      color: AppColors.primary,
      backgroundColor: AppColors.border,
    );
  }
}
