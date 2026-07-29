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
}
