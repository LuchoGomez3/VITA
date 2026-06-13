import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/ear_tag_color_selector.dart';
import 'package:go_router/go_router.dart';

/// Primer paso del flujo de alta manual de animal.
///
/// Por ahora esta pantalla define la carcasa visual del paso 1 de 4.
/// Mas adelante puede conectarse a validaciones, cubit y navegacion real entre
/// pasos sin perder la estructura base ya aprobada por diseno.
class RegistrarAnimalPage extends StatefulWidget {
  /// Crea una nueva instancia de la pantalla de registro de animal.
  const RegistrarAnimalPage({super.key});

  /// Crea una nueva instancia del estado de la pantalla de registro de animal.
  @override
  State<RegistrarAnimalPage> createState() => _RegistrarAnimalPageState();
}

/// Estado de la pantalla de registro de animal.
class _RegistrarAnimalPageState extends State<RegistrarAnimalPage> {
  /// Controlador del campo de RFID.
  final _rfidController = TextEditingController();
  /// Controlador del campo de serie.
  final _serieController = TextEditingController();
  /// Controlador del campo de número de caravana visual.
  final _visualNumberController = TextEditingController();

  @override
  void dispose() {
    /// Libera los controladores de los campos.
    _rfidController.dispose();
    _serieController.dispose();
    _visualNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App bar para el paso actual del flujo.
      appBar: AppBar(
        /// Centra el titulo.
        centerTitle: true,
        /// Boton de cerrar.
        leading: IconButton(
          /// Icono de cerrar.
          icon: const Icon(Icons.close),
          onPressed: _handleClose,
        ),
        /// Espacio para el boton de cerrar.
        actions: const [
          /// Espacio para el boton de cerrar.
          SizedBox(width: 48),
        ],
        /// Titulo compuesto del app bar para el paso actual del flujo.
        title: const _RegisterAnimalAppBarTitle(),
      ),
      body: SafeArea(
        /// Scrollable para el contenido de la pantalla.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Titulo del formulario de ingreso manual.
              const Text(
                AnimalRegisterStrings.manualEntryTitle,
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: AppSpacing.xs),
              /// Descripcion del formulario de ingreso manual.
              const Text(
                AnimalRegisterStrings.manualEntryDescription,
                style: AppTypography.pageBodyTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              /// Campo de RFID.
              AppTextFormField(
                controller: _rfidController,
                title: AnimalRegisterStrings.rfidFieldTitle,
                hintText: AnimalRegisterStrings.rfidFieldHint,
                keyboardType: TextInputType.number,
                helperText: ' ',
              ),
              const SizedBox(height: AppSpacing.sm),
              /// Campos de serie y número de caravana visual.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _serieController,
                      title: AnimalRegisterStrings.seriesFieldTitle,
                      hintText: AnimalRegisterStrings.seriesFieldHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _visualNumberController,
                      title: AnimalRegisterStrings.visualNumberFieldTitle,
                      hintText: AnimalRegisterStrings.visualNumberFieldHint,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              /// Titulo del campo de color de caravana.
              const Text(
                AnimalRegisterStrings.earTagColorTitle,
                style: AppTypography.formFieldLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              /// Selector de colores de caravana.
              EarTagColorSelector(
                options: AnimalRegisterStrings.earTagColorOptions,
                onChanged: (color) {
                },
                isSelected: false,
              ),
              const SizedBox(height: AppSpacing.lg),
              /// Boton de prueba con bastón Bluetooth.
              AppOutlinedButton(
                label: AnimalRegisterStrings.bluetoothButtonLabel,
                icon: const Icon(Icons.bluetooth),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        /// Boton de siguiente.
        child: AppFilledButton(
          label: AnimalRegisterStrings.nextButtonLabel,
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {},
        ),
      ),
    );
  }

  /// Maneja el cierre de la pantalla.
  void _handleClose() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }
}

/// Titulo compuesto del app bar para el paso actual del flujo.
class _RegisterAnimalAppBarTitle extends StatelessWidget {
  /// Crea un nuevo titulo compuesto del app bar para el paso actual del flujo.
  const _RegisterAnimalAppBarTitle();

  /// Construye el titulo compuesto del app bar para el paso actual del flujo.
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          AnimalRegisterStrings.pageTitle,
          style: AppTypography.appBarTitle,
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          AnimalRegisterStrings.pageStepSubtitle,
          style: AppTypography.appBarSubtitle,
        ),
      ],
    );
  }
}
