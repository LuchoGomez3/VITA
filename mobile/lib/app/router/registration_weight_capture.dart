import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_basic_data_step.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_method_sheet.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';
import 'package:go_router/go_router.dart';

/// Abre la captura elegida y devuelve el peso al alta que sigue en la pila.
Future<CapturedInitialWeight?> captureRegistrationWeight(BuildContext context) async {
  final method = await chooseWeighingMethod(context);
  if (method == null || !context.mounted) return null;

  if (method == WeighingMethod.photo) {
    final weightKg = await context.push<double>(AppRoutes.visionWeightCapture);
    return weightKg == null ? null : (weightKg: weightKg, method: AnimalWeighingMethod.artificialIntelligence);
  }

  final weightKg = await context.push<double>(
    AppRoutes.weighing,
    extra: method == WeighingMethod.bluetooth ? WeighingCaptureTab.bluetooth : WeighingCaptureTab.manual,
  );
  // La opción Bluetooth ofrece carga manual mientras no recibe lecturas de balanza.
  return weightKg == null ? null : (weightKg: weightKg, method: AnimalWeighingMethod.manual);
}
