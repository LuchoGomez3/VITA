/// Textos base del flujo de alta manual de animal.
class AnimalRegisterStrings {
  const AnimalRegisterStrings._();

  /// Error al leer los establecimientos disponibles sin conexion.
  static const establishmentsLoadError = 'No se pudieron cargar los establecimientos guardados.';

  /// Etiqueta del selector que contextualiza el alta.
  static const establishmentSelectorLabel = 'Establecimiento';

  /// Ayuda visible antes de seleccionar el establecimiento del animal.
  static const establishmentSelectorHint = 'Seleccioná un establecimiento';

  /// Validacion cuando el alta todavia no tiene establecimiento.
  static const establishmentRequired = 'Seleccioná un establecimiento antes de guardar.';

  /// Estado vacio cuando el usuario no tiene establecimientos disponibles.
  static const noEstablishmentsMessage = 'No hay establecimientos disponibles para registrar el animal.';

  /// Error al leer los lotes disponibles desde el almacenamiento local.
  static const destinationsLoadError = 'No se pudieron cargar los lotes guardados.';

  /// Estado vacío cuando todavía no existen lotes activos offline.
  static const noActiveLotsMessage = 'No hay lotes activos disponibles. Creá o activá un lote antes de continuar.';

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

  /// Error cuando la caravana ya está guardada localmente.
  static const rfidAlreadyRegistered = 'Esta caravana ya está registrada en el dispositivo.';

  /// Error de formato de la caravana electrónica.
  static const rfidInvalid = 'Ingresá una caravana RFID válida de 15 dígitos.';

  /// Titulo del campo de serie.
  static const seriesFieldTitle = 'Serie';

  /// Hint del campo de serie.
  static const seriesFieldHint = 'Ej. 2024';

  /// Titulo del campo de número de caravana visual.
  static const visualNumberFieldTitle = 'N° caravana visual';

  /// Hint del campo de número de caravana visual.
  static const visualNumberFieldHint = 'Ej. 1048';

  /// Titulo del boton de prueba con bastón Bluetooth.
  static const bluetoothButtonLabel = 'Probar con bastón Bluetooth';

  /// Titulo del boton de siguiente.
  static const nextButtonLabel = 'Siguiente';

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

  /// Estado vacio cuando la sincronizacion no dejo categorias disponibles.
  static const noCategoriesMessage = 'No hay categorías disponibles. Sincronizá los datos e intentá nuevamente.';

  /// Validacion cuando el productor no selecciono una categoria.
  static const categoryRequired = 'Seleccioná una categoría antes de guardar.';

  /// Titulo del campo opcional de peso al nacer.
  static const stepTwoBirthWeightTitle = 'Peso al nacer • opcional';

  /// Ejemplo de formato para el peso al nacer.
  static const stepTwoBirthWeightHint = '32,5';

  /// Texto del boton que vuelve al paso anterior.
  static const stepTwoBackButton = 'Atrás';

  /// Texto del boton que avanza al siguiente paso.
  static const stepTwoNextButton = 'Siguiente';

  // TODO(agusf): eliminar los datos mock restantes cuando identificacion,
  // catalogos y genealogia expongan sus fuentes offline reales.

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
  static const stepThreeSearchHint = 'Buscar caravana visual o RFID...';

  /// Error inline cuando la caravana no corresponde a un progenitor elegible.
  static const parentNotFound = 'No se encontró la caravana en este establecimiento.';

  /// Encabezado principal de la seccion de destino.
  static const stepThreeDestinationTitle = 'DESTINO';

  /// Descripcion de la asignacion de potrero.
  static const stepThreeDestinationDescription = 'Potrero al que ingresa el animal.';

  /// Texto del boton que vuelve al paso anterior.
  static const stepThreeBackButton = 'Atrás';

  /// Texto del boton que avanza al siguiente paso.
  static const stepThreeNextButton = 'Siguiente';

  // Paso 4: revision.

  /// Subtitulo del app bar para el paso de revision.
  static const stepFourSubtitle = 'Paso 4 de 4 • Revisar';

  /// Titulo principal del paso de revision.
  static const stepFourTitle = 'REVISAR ANTES DE GUARDAR';

  /// Descripcion del paso de revision.
  static const stepFourDescription =
      'Tocá cualquier sección para editarla. El alta se guarda en este dispositivo y se sincroniza cuando vuelva la señal.';

  /// Titulo de la seccion de identificacion.
  static const stepFourIdentificationTitle = 'IDENTIFICACIÓN';

  /// Titulo de la seccion de datos basicos.
  static const stepFourBasicDataTitle = 'DATOS BÁSICOS';

  /// Titulo de la seccion de genealogia y destino.
  static const stepFourGenealogyTitle = 'GENEALOGÍA Y DESTINO';

  /// Numero visual usado en la caravana de revision.
  static const stepFourIdentificationVisualTag = '003 1295';

  /// RFID mostrado en la seccion de identificacion.
  static const stepFourIdentificationRfid = '982 000 412 991 416';

  /// Label del campo raza.
  static const stepFourBreedLabel = 'Raza';

  /// Valor mock del campo raza.
  static const stepFourBreedValue = 'Aberdeen Angus';

  /// Label del campo sexo.
  static const stepFourSexLabel = 'Sexo';

  /// Valor mock del campo sexo.
  static const stepFourSexValue = 'Hembra';

  /// Label del campo fecha de nacimiento.
  static const stepFourBirthDateLabel = 'Fecha de nacimiento';

  /// Valor mock del campo fecha de nacimiento.
  static const stepFourBirthDateValue = '14/03/2025 · 2 m 1 día';

  /// Label del campo categoria.
  static const stepFourCategoryLabel = 'Categoría';

  /// Label del campo peso al nacer.
  static const stepFourBirthWeightLabel = 'Peso al nacer';

  /// Valor mock del campo peso al nacer.
  static const stepFourBirthWeightValue = '32,5 kg';

  /// Label del campo madre.
  static const stepFourMotherLabel = 'Madre';

  /// Label del campo padre.
  static const stepFourFatherLabel = 'Padre';

  /// Value displayed when optional information is missing.
  static const stepFourNoDataValue = '— (sin datos)';

  /// Label del campo potrero.
  static const stepFourDestinationLabel = 'Potrero';

  /// Label del establecimiento en la revision del alta.
  static const stepFourEstablishmentLabel = 'Establecimiento';

  /// Valor mock del campo potrero.
  static const stepFourDestinationValue = 'La Cumbre · 142 ha';

  /// Texto del boton para volver al paso anterior.
  static const stepFourBackButton = 'Atrás';

  /// Texto del boton para guardar el animal.
  static const stepFourSaveButton = 'Guardar animal';

  /// Texto del boton para editar una seccion de revision.
  static const stepFourEditButton = 'Editar';

  // Pantalla de exito.

  /// Titulo principal de la pantalla de exito.
  static const successTitle = 'Animal dado de alta';

  /// Subtitulo de la pantalla de exito.
  static const successSubtitle = 'La ternera 003 1295 ya forma parte del rodeo de La Sirena.';

  /// Texto del boton para iniciar otra alta.
  static const successRegisterAnotherButton = 'Dar de alta otro animal';

  /// Texto del boton para ver la ficha del animal.
  static const successViewDetailsButton = 'Ver ficha de 003 1295';

  /// Texto de la accion para volver al inicio.
  static const successBackHomeButton = 'Volver al inicio';

  /// Numero visual mock mostrado en la tarjeta de exito.
  static const successMockVisualTag = '003 1295';

  /// Titulo mock del animal registrado.
  static const successMockAnimalTitle = 'Aberdeen Angus · Ternera';

  /// RFID mock del animal registrado.
  static const successMockRfid = '982 000 412 991 416';

  /// Destino mock del animal registrado.
  static const successMockDestination = 'La Cumbre';
}
