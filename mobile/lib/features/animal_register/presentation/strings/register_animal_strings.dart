import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/ear_tag_color_selector.dart';

/// Textos base del flujo de alta manual de animal.
class AnimalRegisterStrings {

  const AnimalRegisterStrings._();
  /// Titulo de la pagina.  
  static const pageTitle = 'Alta de animal';
  /// Subtitulo de la pagina.
  static const pageStepSubtitle = 'Paso 1 de 4 • Identificación';
  /// Titulo del formulario de ingreso manual.

  static const manualEntryTitle = 'INGRESO MANUAL';
  /// Descripcion del formulario de ingreso manual.
  static const manualEntryDescription =
      'Si no tenés el bastón a mano, ingresá los 15 dígitos de la caravana RFID y el número visual .';

  /// Titulo del campo de RFID.
  static const rfidFieldTitle = 'RFID • 15 dígitos';
  /// Hint del campo de RFID.
  static const rfidFieldHint = 'Ingresá los 15 dígitos';

  /// Titulo del campo de serie.
  static const seriesFieldTitle = 'Serie';
  /// Hint del campo de serie.
  static const seriesFieldHint = 'Ej. 2024';

  /// Titulo del campo de número de caravana visual.
  static const visualNumberFieldTitle = 'N° caravana visual';
  /// Hint del campo de número de caravana visual.
  static const visualNumberFieldHint = 'Ej. 1048';

  /// Titulo del campo de color de caravana.
  static const earTagColorTitle = 'Color de caravana';

  /// Titulo del boton de prueba con bastón Bluetooth.  
  static const bluetoothButtonLabel = 'Probar con bastón Bluetooth';
  /// Titulo del boton de siguiente.
  static const nextButtonLabel = 'Siguiente';

  /// Opciones de color de caravana. (Agus: Esto lo voy a cambiar)
  static const earTagColorOptions = [
    EarTagColorOption(
      name: 'Amarillo',
      color: AppColors.earTagYellow,
      isSelected: false,
    ),
    EarTagColorOption(
      name: 'Beige',
      color: AppColors.earTagBeige,
      isSelected: false,
    ),
    EarTagColorOption(
      name: 'Lila',
      color: AppColors.earTagLilac,
      isSelected: false,
    ),
    EarTagColorOption(
      name: 'Naranja',
      color: AppColors.earTagOrange,
      isSelected: false,
    ),
  ];
}
