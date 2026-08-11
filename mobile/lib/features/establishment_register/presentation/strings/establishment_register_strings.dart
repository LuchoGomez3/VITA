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

  /// Mensaje de validacion mock del campo CUIT cuando el formato es valido.
  static const stepTwoCuitValidatedCaption = 'Cecilia Lazarte · validado en AFIP';

  /// Mensaje cuando el digito verificador del CUIT no coincide.
  static const stepTwoCuitInvalidCheckDigitMessage = 'El CUIT ingresado no es válido.';

  /// Mensaje cuando el CUIT todavia no tiene los once digitos.
  static const stepTwoCuitIncompleteMessage = 'Ingresá un CUIT completo (11 dígitos).';

  /// Titulo del campo numero de RENSPA.
  static const stepTwoRenspaFieldTitle = 'Número de RENSPA';

  /// Placeholder del campo numero de RENSPA.
  static const stepTwoRenspaFieldHint = 'Ej. 07.123.0.00456/01';

  /// Mensaje cuando el RENSPA cumple el formato `NN.NNN.N.NNNNN/NN`.
  static const stepTwoRenspaValidFormatMessage = 'Formato válido.';

  /// Mensaje cuando el RENSPA todavia no tiene el formato completo.
  static const stepTwoRenspaIncompleteMessage = 'Ingresá el RENSPA completo (formato NN.NNN.N.NNNNN/NN).';

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

  /// Titulo de seccion del paso 3.
  static const stepThreeSectionTitle = 'Ubicación geográfica';

  /// Descripcion del paso 3.
  static const stepThreeSectionDescription =
      'Marcá un punto de referencia del campo (el casco, la tranquera o el '
      'centro). Después vas a poder dibujar el perímetro completo.';

  /// Titulo del campo provincia.
  static const stepThreeProvinciaFieldTitle = 'Provincia';

  /// Opciones mock de provincia.
  static const stepThreeProvinciaOptions = ['Córdoba', 'Buenos Aires', 'Santa Fe', 'Mendoza'];

  /// Titulo del campo departamento.
  static const stepThreeDepartamentoFieldTitle = 'Departamento';

  /// Opciones mock de departamento.
  static const stepThreeDepartamentoOptions = ['Río Cuarto', 'Capital', 'Juárez Celman'];

  /// Titulo del campo localidad.
  static const stepThreeLocalidadFieldTitle = 'Localidad más cercana';

  /// Texto de ayuda del campo localidad.
  static const stepThreeLocalidadFieldHelper = 'Autocompleta con el padrón del INDEC.';

  /// Opciones mock de localidad.
  static const stepThreeLocalidadOptions = ['Coronel Moldes', 'Río Cuarto', 'Vicuña Mackenna'];

  /// Titulo del bloque de coordenadas.
  static const stepThreeCoordinatesFieldTitle = 'Coordenadas del punto de referencia';

  /// Confirmación de toma de coordenadas por GPS.
  static const stepThreeGpsConfirmedCaption = 'Tomada del GPS · precisión 4 m';

  /// Placeholder de coordenadas mientras no se confirmó la ubicación.
  static const stepThreeCoordinateUnconfirmedPlaceholder = '—';

  /// Boton para tomar la ubicación actual (mock).
  static const stepThreeUseCurrentLocationButton = 'Usar mi ubicación actual';

  /// Titulo de la vista previa del mapa.
  static const stepThreePreviewLabel = 'Vista previa';

  /// Texto del banner de instrucciones del paso 4.
  static const stepFourBannerText = 'Tocá los vértices del campo. Vas a poder dividir en potreros más adelante.';

  /// Etiqueta de superficie en el chip flotante del paso 4.
  static const stepFourSurfaceLabel = 'Superficie';

  /// Etiqueta de vértices en el chip flotante del paso 4.
  static const stepFourVerticesLabel = 'Vértices';

  /// Tooltip del boton deshacer.
  static const stepFourUndoTooltip = 'Deshacer';

  /// Tooltip del boton borrar.
  static const stepFourClearTooltip = 'Borrar';

  /// Tooltip del boton de capa.
  static const stepFourLayerTooltip = 'Capa';

  /// Texto del hint inferior del paso 4.
  static const stepFourHintText = 'Tocá cualquier vértice para arrastrarlo';

  /// Boton para editar una seccion desde la revision.
  static const reviewEditButton = 'Editar';

  /// Titulo de la seccion 1 de revision.
  static const reviewSectionOneTitle = 'Identificación';

  /// Titulo de la seccion 2 de revision.
  static const reviewSectionTwoTitle = 'RENSPA y titular';

  /// Titulo de la seccion 3 de revision.
  static const reviewSectionThreeTitle = 'Ubicación';

  /// Titulo de la seccion 4 de revision.
  static const reviewSectionFourTitle = 'Superficie delimitada';

  /// Etiqueta de nombre en la revision.
  static const reviewNombreLabel = 'Nombre';

  /// Etiqueta de produccion en la revision.
  static const reviewProduccionLabel = 'Producción';

  /// Etiqueta de descripcion en la revision.
  static const reviewDescripcionLabel = 'Descripción';

  /// Etiqueta de titular en la revision.
  static const reviewTitularLabel = 'Titular';

  /// Nombre mock del titular, consistente con la validación mock de CUIT.
  static const reviewOwnerNameMock = 'Cecilia Lazarte';

  /// Etiqueta de CUIT en la revision.
  static const reviewCuitLabel = 'CUIT';

  /// Etiqueta de RENSPA en la revision.
  static const reviewRenspaLabel = 'RENSPA';

  /// Etiqueta de provincia en la revision.
  static const reviewProvinciaLabel = 'Provincia';

  /// Etiqueta de departamento en la revision.
  static const reviewDepartamentoLabel = 'Departamento';

  /// Etiqueta de localidad en la revision.
  static const reviewLocalidadLabel = 'Localidad';

  /// Etiqueta de coordenadas en la revision.
  static const reviewCoordenadasLabel = 'Coordenadas';

  /// Chip de unidad productiva en la revision.
  static const reviewUnidadProductivaChipLabel = '1 unidad productiva';

  /// Titulo de la nota de rol en la revision.
  static const reviewOwnerNoteTitle = 'Tu rol';

  /// Mensaje de la nota de rol en la revision.
  static const reviewOwnerNoteMessage =
      'Vas a quedar como Owner del establecimiento. Después podés invitar '
      'capataces y veterinarios.';

  /// Titulo de la pantalla de éxito.
  static const successTitle = '¡Listo!';

  /// Sufijo del subtitulo de la pantalla de éxito (el nombre va antes).
  static const successSubtitleSuffix = ' ya está registrada. Quedaste como Owner.';

  /// Etiqueta del chip de rol en la tarjeta de éxito.
  static const successOwnerChipLabel = 'Owner';

  /// Etiqueta del mini-stat de superficie.
  static const successSurfaceStatLabel = 'Superficie';

  /// Etiqueta del mini-stat de cabezas.
  static const successAnimalsStatLabel = 'Cabezas';

  /// Etiqueta del mini-stat de unidades productivas.
  static const successProductionUnitsStatLabel = 'UP';

  /// Titulo de la sección de próximos pasos.
  static const successNextStepsTitle = 'Próximos pasos sugeridos';

  /// Titulo de la sugerencia de dividir en potreros.
  static const successNextStepDivideLabel = 'Dividir el campo en potreros';

  /// Subtitulo de la sugerencia de dividir en potreros.
  static const successNextStepDivideSub = 'Subdividí la superficie en potreros';

  /// Titulo de la sugerencia de invitar al capataz.
  static const successNextStepInviteLabel = 'Invitar al capataz';

  /// Subtitulo de la sugerencia de invitar al capataz.
  static const successNextStepInviteSub = 'Para que pueda cargar pesajes y sanidad';

  /// Titulo de la sugerencia de dar de alta el primer animal.
  static const successNextStepAnimalLabel = 'Dar de alta el primer animal';

  /// Subtitulo de la sugerencia de dar de alta el primer animal.
  static const successNextStepAnimalSub = 'Empezá a cargar tu rodeo';

  /// Boton para volver al inicio desde la pantalla de éxito.
  static const successGoHomeButton = 'Ir al inicio';

  /// Titulo del modal de falta de conexión (creación online-only).
  static const offlineModalTitle = 'Necesitás conexión a internet';

  /// Mensaje del modal de falta de conexión.
  static const offlineModalMessage =
      'Para crear el establecimiento necesitamos validar el RENSPA y el CUIT '
      'contra el backend. Probá de nuevo cuando tengas conexión.';

  /// Titulo de la recomendación de Wi-Fi del modal offline.
  static const offlineWifiTitle = 'Wi-Fi de la casa o galpón';

  /// Subtitulo de la recomendación de Wi-Fi del modal offline.
  static const offlineWifiSubtitle = 'Recomendado';

  /// Titulo de la recomendación de datos móviles del modal offline.
  static const offlineMobileDataTitle = 'Datos móviles';

  /// Subtitulo de la recomendación de datos móviles del modal offline.
  static const offlineMobileDataSubtitle = 'Probá cerca de la ruta';

  /// Boton para reintentar desde el modal offline.
  static const offlineRetryButton = 'Reintentar';

  /// Icono de nube tachada (sin conexión).
  static const cloudOffIcon = 'assets/icons/cloud_off.svg';

  /// Icono de reintentar.
  static const cachedIcon = 'assets/icons/cached.svg';

  /// Icono de nube (conectividad disponible).
  static const cloudIcon = 'assets/icons/cloud.svg';

  /// Mensaje inline cuando el backend rechaza el RENSPA por estar duplicado.
  static const renspaConflictMessage =
      'Este RENSPA ya está registrado. Revisalo antes de continuar.';
}
