/// Textos centralizados del wizard de registro de establecimiento.
class EstablishmentRegisterStrings {
  const EstablishmentRegisterStrings._();

  /// Titulo compartido del app bar del wizard.
  static const pageTitle = 'Nuevo establecimiento';

  /// Subtitulo del paso 1.
  static const stepOneSubtitle = 'Paso 1 de 4 · Identificación';

  /// Subtitulo del paso 2.
  static const stepTwoSubtitle = 'Paso 2 de 4 · RENSPA y titular';

  /// Subtitulo del paso 3.
  static const stepThreeSubtitle = 'Paso 3 de 4 · Ubicación';

  /// Subtitulo del paso 4.
  static const stepFourSubtitle = 'Paso 4 de 4 · Delimitar superficie';

  /// Titulo de la pantalla de revision.
  static const reviewTitle = 'Revisar y crear';

  /// Subtitulo de la pantalla de revision.
  static const reviewSubtitle = 'Último paso antes de crear el establecimiento';

  /// Boton para avanzar de paso.
  static const nextButtonLabel = 'Siguiente';

  /// Boton para retroceder de paso.
  static const backButtonLabel = 'Atrás';

  /// Boton de avance especifico del paso de superficie.
  static const surfaceStepNextButtonLabel = 'Revisar';

  /// Boton final para crear el establecimiento.
  static const createButtonLabel = 'Crear establecimiento';

  /// Texto del boton mientras se envia el registro.
  static const savingButtonLabel = 'Guardando...';

  /// Nombre de usuario mock mostrado en el estado vacío.
  static const emptyStateUserName = 'Cecilia L.';

  /// Boton para cerrar sesion desde el estado vacío.
  static const emptyStateSignOut = 'Salir';

  /// Titulo del estado vacío.
  static const emptyStateTitle = 'Aún no tenés establecimientos';

  /// Descripcion del estado vacío.
  static const emptyStateDescription =
      'Como dueño podés registrar tu campo: nombre, RENSPA y ubicación. '
      'Después agregás potreros, equipo y animales.';

  /// Item 1 del checklist del estado vacío.
  static const emptyStateChecklistItem1Label = 'Identificación del campo';

  /// Subtitulo del item 1 del checklist.
  static const emptyStateChecklistItem1Sub = 'Nombre y descripción';

  /// Item 2 del checklist del estado vacío.
  static const emptyStateChecklistItem2Label = 'RENSPA y titular';

  /// Subtitulo del item 2 del checklist.
  static const emptyStateChecklistItem2Sub = 'CUIT del dueño + número SENASA';

  /// Item 3 del checklist del estado vacío.
  static const emptyStateChecklistItem3Label = 'Ubicación geográfica';

  /// Subtitulo del item 3 del checklist.
  static const emptyStateChecklistItem3Sub = 'Provincia, departamento, coordenadas';

  /// Item 4 del checklist del estado vacío.
  static const emptyStateChecklistItem4Label = 'Delimitar superficie';

  /// Subtitulo del item 4 del checklist.
  static const emptyStateChecklistItem4Sub = 'Dibujar el perímetro del campo';

  /// Boton primario para iniciar el registro.
  static const emptyStateRegisterButton = 'Registrar establecimiento';

  /// Boton secundario para sumarse a un establecimiento existente.
  static const emptyStateJoinExistingButton = 'Sumarme a uno existente con código';

  /// Titulo de seccion del paso 1.
  static const stepOneSectionTitle = 'Identificación del campo';

  /// Descripcion del paso 1.
  static const stepOneSectionDescription =
      'Este es el nombre con el que vas a ver el establecimiento en la app. '
      'No tiene que coincidir con el catastro.';

  /// Titulo del campo nombre.
  static const stepOneNameFieldTitle = 'Nombre del establecimiento';

  /// Placeholder del campo nombre.
  static const stepOneNameFieldHint = 'Ej. La Sirena';

  /// Texto de ayuda del campo nombre.
  static const stepOneNameFieldHelper = 'Hasta 60 caracteres · visible para tu equipo.';

  /// Titulo del campo descripción.
  static const stepOneDescriptionFieldTitle = 'Descripción';

  /// Sufijo que marca la descripción como opcional.
  static const stepOneDescriptionFieldOptionalSuffix = ' · opcional';

  /// Placeholder del campo descripción.
  static const stepOneDescriptionFieldHint = 'Ej. Cría y recría de Aberdeen Angus.';

  /// Titulo del selector de tipo de producción.
  static const stepOneProductionTypeTitle = 'Tipo de producción';

  /// Texto de ayuda del selector de tipo de producción.
  static const stepOneProductionTypeHelper = 'Podés elegir más de uno. Esto sólo es para reportes internos.';

  /// Opciones disponibles de tipo de producción.
  static const stepOneProductionTypeOptions = [
    'Cría',
    'Recría',
    'Invernada',
    'Ciclo completo',
    'Tambo',
  ];

  /// Titulo de seccion del paso 2.
  static const stepTwoSectionTitle = 'RENSPA y titular';

  /// Descripcion del paso 2.
  static const stepTwoSectionDescription =
      'El RENSPA es el código que SENASA asigna a cada unidad productiva '
      'oficial. Lo encontrás en el certificado del establecimiento.';

  /// Titulo del campo CUIT del titular.
  static const stepTwoCuitFieldTitle = 'CUIT del titular';

  /// Placeholder del campo CUIT del titular.
  static const stepTwoCuitFieldHint = 'Ej. 20-21456789-3';

  /// Mensaje de validacion mock del campo CUIT.
  static const stepTwoCuitValidatedCaption = 'Cecilia Lazarte · validado en AFIP';

  /// Titulo del campo numero de RENSPA.
  static const stepTwoRenspaFieldTitle = 'Número de RENSPA';

  /// Placeholder del campo numero de RENSPA.
  static const stepTwoRenspaFieldHint = 'Ej. 07.123.0.00456/01';

  /// Etiqueta del segmento provincia del desglose de RENSPA.
  static const renspaProvinciaLabel = 'Provincia';

  /// Etiqueta del segmento departamento del desglose de RENSPA.
  static const renspaDepartamentoLabel = 'Depto.';

  /// Etiqueta del segmento actividad del desglose de RENSPA.
  static const renspaActividadLabel = 'Activ.';

  /// Etiqueta del segmento titular del desglose de RENSPA.
  static const renspaTitularLabel = 'Titular';

  /// Etiqueta del segmento unidad productiva del desglose de RENSPA.
  static const renspaUnidadProductivaLabel = 'U. Prod.';

  /// Explicación del desglose de RENSPA.
  static const stepTwoRenspaCaption =
      '07 = Córdoba · 123 = Río Cuarto · 0 = ganadería bovina · '
      '00456 = titular · 01 = primera unidad productiva.';

  /// Titulo de la nota de validación SENASA.
  static const stepTwoSenasaCalloutTitle = 'Validación SENASA';

  /// Mensaje de la nota de validación SENASA.
  static const stepTwoSenasaCalloutMessage =
      'Cuando vuelva la conexión vamos a verificar el RENSPA contra el '
      'padrón oficial. Si no coincide te avisamos.';

  /// Boton para agregar otra unidad productiva.
  static const stepTwoAddProductionUnitButton = 'Agregar otra unidad productiva (otro RENSPA)';
}
