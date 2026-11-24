import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/weighing/presentation/mock/weighing_mock.dart';
import 'package:frontend_mayoral/features/weighing/presentation/pages/weighing_page.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';
import 'package:go_router/go_router.dart';

/// Animal que se va a pesar.
typedef WeighingSubject = ({
  String animalId,
  String establishmentId,
  String visualTag,
  String rfidTagNumber,
  String breedAndCategory,
  int currentWeightKg,
});

/// Opciones ofrecidas al iniciar un pesaje.
enum WeighingMethod {
  /// Captura por balanza.
  bluetooth(WeighingStrings.methodBluetooth, Icons.bluetooth),

  /// Ingreso de kilos por teclado.
  manual(WeighingStrings.methodManual, Icons.dialpad),

  /// Estimación a partir de una foto.
  photo(WeighingStrings.methodPhoto, Icons.photo_camera_outlined);

  const WeighingMethod(this._label, this._icon);

  final String _label;
  final IconData _icon;
}

/// Muestra los métodos de pesaje y devuelve la opción elegida.
Future<WeighingMethod?> chooseWeighingMethod(BuildContext context) {
  return showModalBottomSheet<WeighingMethod>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Text(WeighingStrings.methodSheetTitle, style: AppTypography.pageTitle),
          ),
          for (final method in WeighingMethod.values)
            ListTile(
              leading: Icon(method._icon, color: AppColors.primary),
              title: Text(method._label, style: AppTypography.mediumEmphasis),
              onTap: () => Navigator.of(sheetContext).pop(method),
            ),
        ],
      ),
    ),
  );
}

/// Abre el pesaje de un animal registrado y avisa si hay que recargar su peso.
Future<bool> startWeighing(BuildContext context, WeighingSubject subject) async {
  final method = await chooseWeighingMethod(context);
  if (method == null || !context.mounted) {
    return false;
  }

  switch (method) {
    case WeighingMethod.bluetooth || WeighingMethod.manual:
      final saved = await context.push<bool>(
        AppRoutes.weighing,
        extra: WeighingRequest(
          animalId: subject.animalId,
          establishmentId: subject.establishmentId,
          animal: WeighingAnimalMock(
            visualTag: subject.visualTag,
            rfid: subject.rfidTagNumber,
            breedAndCategory: subject.breedAndCategory,
            weightKg: subject.currentWeightKg,
          ),
          initialTab: method == WeighingMethod.bluetooth ? WeighingCaptureTab.bluetooth : WeighingCaptureTab.manual,
        ),
      );
      return saved ?? false;
    case WeighingMethod.photo:
      // Pesaje IA (modelo de visión on-device). La pantalla elige el animal por
      // su cuenta y no informa si guardó: se recarga igual al volver.
      await context.push<void>(AppRoutes.visionWeighing);
      return true;
  }
}
