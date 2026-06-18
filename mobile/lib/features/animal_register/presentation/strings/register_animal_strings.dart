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
    ),
    EarTagColorOption(
      name: 'Beige',
      color: AppColors.earTagBeige,
    ),
    EarTagColorOption(
      name: 'Lila',
      color: AppColors.earTagLilac,
    ),
    EarTagColorOption(
      name: 'Naranja',
      color: AppColors.earTagOrange,
    ),
  ];

  // Paso 2: datos basicos.

  /// Subtitulo del app bar para el paso de datos basicos.
  static const stepTwoSubtitle = 'Paso 2 de 4 • Datos básicos';

  /// Encabezado principal de la seccion del paso 2.
  static const stepTwoSectionTitle = 'DATOS BÁSICOS';

  /// Titulo del selector de raza.
  static const stepTwoBreedTitle = 'Raza';

  /// Hint visible cuando no hay una raza seleccionada.
  static const stepTwoBreedHint = 'Seleccioná una raza';

  /// Razas mock disponibles hasta integrar la fuente de datos real.
  static const stepTwoBreedOptions = [
    'Aberdeen Angus',
    'Hereford',
    'Braford',
    'Brangus',
  ];

  /// Titulo del selector de sexo.
  static const stepTwoSexTitle = 'Sexo';

  /// Etiqueta para la opcion hembra.
  static const stepTwoFemale = 'Hembra';

  /// Etiqueta para la opcion macho.
  static const stepTwoMale = 'Macho';

  /// Titulo del campo de fecha de nacimiento.
  static const stepTwoBirthDateTitle = 'Fecha de nacimiento';

  /// Hint del campo de fecha de nacimiento.
  static const stepTwoBirthDateHint = 'Seleccioná una fecha';

  /// Atajo para seleccionar la fecha actual.
  static const stepTwoToday = 'Hoy';

  /// Atajo para seleccionar una fecha un mes anterior.
  static const stepTwoOneMonthAgo = 'Hace 1 m';

  /// Atajo para seleccionar una fecha seis meses anterior.
  static const stepTwoSixMonthsAgo = 'Hace 6 m';

  /// Atajo para seleccionar una fecha un año anterior.
  static const stepTwoOneYearAgo = 'Hace 1 año';

  /// Titulo del selector de categoria.
  static const stepTwoCategoryTitle = 'Categoría';

  /// Categorias mock disponibles hasta integrar las reglas del dominio.
  static const stepTwoCategories = [
    'Ternera',
    'Ternero',
    'Vaquillona',
    'Vaca',
    'Novillo',
    'Toro',
  ];

  /// Aclaracion sobre la futura sugerencia automatica de categoria.
  static const stepTwoCategorySuggestion = 'Sugerido automáticamente por fecha de nacimiento y sexo.';

  /// Titulo del campo opcional de peso al nacer.
  static const stepTwoBirthWeightTitle = 'Peso al nacer • opcional';

  /// Ejemplo de formato para el peso al nacer.
  static const stepTwoBirthWeightHint = '32,5';

  /// Texto del boton que vuelve al paso anterior.
  static const stepTwoBackButton = 'Atrás';

  /// Texto del boton que avanza al siguiente paso.
  static const stepTwoNextButton = 'Siguiente';

  // Datos mock hasta conectar el flujo con su fuente de datos real.

  /// RFID mock mostrado en el resumen de identificacion.
  static const stepTwoMockRfid = '982 000 412 991 416';

  /// Numero visual mock mostrado en la caravana.
  static const stepTwoMockVisualTag = '003 1295';

  /// Descripcion mock de la lectura de la caravana.
  static const stepTwoMockReading = 'Caravana 003 1295 · leída a las 11:42';

  // Paso 3: genealogia y destino.

  /// Subtitulo del app bar para el paso de genealogia y destino.
  static const stepThreeSubtitle = 'Paso 3 de 4 • Genealogía y destino';

  /// Encabezado principal de la seccion de genealogia.
  static const stepThreeGenealogyTitle = 'GENEALOGÍA · opcional';

  /// Descripcion de la busqueda de madre y padre.
  static const stepThreeGenealogyDescription =
      'Buscá madre y padre entre los animales del establecimiento. '
      'Si no figuran, podés saltar este paso.';

  /// Titulo del selector de madre.
  static const stepThreeMotherTitle = 'Madre';

  /// Titulo del selector de padre.
  static const stepThreeFatherTitle = 'Padre (toro)';

  /// Hint compartido por los buscadores de progenitores.
  static const stepThreeSearchHint = 'Buscar caravana o nombre...';

  /// Encabezado principal de la seccion de destino.
  static const stepThreeDestinationTitle = 'DESTINO';

  /// Descripcion de la asignacion de potrero.
  static const stepThreeDestinationDescription = 'Potrero al que ingresa el animal.';

  /// Texto del boton que vuelve al paso anterior.
  static const stepThreeBackButton = 'Atrás';

  /// Texto del boton que avanza al siguiente paso.
  static const stepThreeNextButton = 'Siguiente';

  /// Nombre mock de la madre seleccionada.
  static const stepThreeMockMotherName = 'Aberdeen Angus';

  /// Numero visual mock de la madre seleccionada.
  static const stepThreeMockMotherTag = '003 0421';

  /// RFID mock de la madre seleccionada.
  static const stepThreeMockMotherRfid = '982 000 412 884 421';

  /// Nombre mock del primer toro sugerido.
  static const stepThreeMockFatherOneName = 'Don Pedro';

  /// Raza mock del primer toro sugerido.
  static const stepThreeMockFatherOneBreed = 'Aberdeen Angus';

  /// Numero visual mock del primer toro sugerido.
  static const stepThreeMockFatherOneTag = '003 0820';

  /// Nombre mock del segundo toro sugerido.
  static const stepThreeMockFatherTwoName = 'Tornado';

  /// Raza mock del segundo toro sugerido.
  static const stepThreeMockFatherTwoBreed = 'Brangus';

  /// Numero visual mock del segundo toro sugerido.
  static const stepThreeMockFatherTwoTag = '003 0612';

  /// Nombre mock del tercer toro sugerido.
  static const stepThreeMockFatherThreeName = 'Capitán';

  /// Raza mock del tercer toro sugerido.
  static const stepThreeMockFatherThreeBreed = 'Hereford';

  /// Numero visual mock del tercer toro sugerido.
  static const stepThreeMockFatherThreeTag = '002 0118';

  /// Etiqueta visible para los candidatos a padre.
  static const stepThreeBullBadge = 'Toro';

  /// Nombre mock del potrero seleccionado.
  static const stepThreeMockDestinationName = 'La Cumbre';

  /// Detalle mock del potrero seleccionado.
  static const stepThreeMockDestinationDetails = '142 ha · 342 animales actualmente';
}
