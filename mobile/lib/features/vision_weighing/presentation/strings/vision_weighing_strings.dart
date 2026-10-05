import 'package:frontend_mayoral/core/constants/feature_strings.dart';

/// Textos compartidos por cámara, revisión y calibración.
abstract final class VisionWeighingStrings {
  /// Título del acceso y la pantalla.
  static const String title = FeatureStrings.visionWeighing;

  /// Instrucción de posicionamiento.
  static const guidance = 'Ubicá al bovino de perfil en la manga. Incluí cabeza, lomo y patas dentro de la guía.';

  /// Recordatorio visible al sostener el teléfono horizontalmente.
  static const framingReminder = 'Asegurate de que el animal esté bien centrado y no se corte ninguna parte.';

  /// Orientación requerida para abarcar el cuerpo completo.
  static const rotate = 'Poné el celular en horizontal';

  /// Aclara que el flujo funciona sin señal.
  static const offline = 'Captura sin conexión';

  /// Disparador.
  static const capture = 'Capturar foto lateral';

  /// Modo de captura con peso real.
  static const calibration = 'Modo Calibración';

  /// Menú de opciones del visor.
  static const settings = 'Configuración';

  /// Selección de una fotografía local para pruebas.
  static const attachPhoto = 'Adjuntar foto';

  /// Error al abrir la galería o leer el archivo elegido.
  static const attachPhotoError = 'No pudimos adjuntar la foto. Intentá elegirla nuevamente.';

  /// Describe la acción disponible al tocar la foto revisada.
  static const expandPhoto = 'Ampliar foto';

  /// Cierra el visor de fotografía a pantalla completa.
  static const closeExpandedPhoto = 'Cerrar foto ampliada';

  /// Ayuda para el ensayo de campo.
  static const calibrationHelp = 'Asociá la foto con el peso real de balanza.';

  /// Etiqueta del peso real.
  static const weight = 'Peso real de balanza (kg)';

  /// Validación del dato manual.
  static const invalidWeight = 'Ingresá un peso mayor a cero, con hasta dos decimales.';

  /// Acción que completa el control visual de la foto.
  static const confirm = 'Confirmar captura';

  /// Acción que registra el peso con el animal elegido.
  static const saveEstimate = 'Guardar pesaje IA';

  /// Rótulo del resultado calculado mediante visión.
  static const estimatedWeight = 'Peso estimado';

  /// Aviso visible sólo cuando captura e inferencia exceden el objetivo.
  static const slowInference = 'La estimación tardó más de 3 segundos.';

  /// Identificador RFID necesario para vincular el peso al animal local.
  static const rfidTag = 'Caravana RFID';

  /// Selección de identidad local para la captura actual.
  static const animalSectionTitle = 'Vincular con un animal';

  /// Explica el alcance local de la asociación.
  static const animalSectionHelp =
      'Elegí un animal local o identificá su caravana con el bastón. El pesaje se guardará al confirmar.';

  /// Los animales se ordenan por actualización; no existe historial de lecturas.
  static const recentAnimals = 'Animales locales recientes';

  /// Estado sin animales locales para el filtro actual.
  static const noRecentAnimals = 'No hay animales locales para mostrar en este establecimiento.';

  /// Nombre del campo que limita la búsqueda del bastón.
  static const establishment = 'Establecimiento';

  /// Ayuda cuando hay varios establecimientos disponibles.
  static const selectEstablishment = 'Seleccioná un establecimiento';

  /// Estado sin catálogo de establecimientos.
  static const noEstablishments = 'No hay establecimientos disponibles en este dispositivo.';

  /// Abre la identificación RFID existente.
  static const scanAnimal = 'Identificar con bastón RFID';

  /// Identificador visual del animal local.
  static const visualTag = 'Caravana visual';

  /// Evita un pesaje sin animal cuando el guardado se habilite.
  static const selectAnimalBeforeSave = 'Seleccioná un animal antes de guardar el pesaje.';

  /// El animal dejó de estar accesible durante la lectura.
  static const animalUnavailable = 'El animal leído ya no está disponible en los datos locales.';

  /// Falló la consulta SQLite o del catálogo offline.
  static const animalLoadError = 'No pudimos cargar los animales locales.';

  /// Reintenta cargar las opciones locales.
  static const retryAnimalLoad = 'Reintentar carga';

  /// Confirma persistencia SQLite exitosa.
  static const saved = 'Pesaje IA guardado en este dispositivo.';

  /// Informa fallos de búsqueda o escritura del pesaje local.
  static const saveError = 'No se pudo guardar el pesaje. Intentá nuevamente.';

  /// Estado de una captura revisada cuando el guardado no está configurado.
  static const captureReviewed = 'Captura revisada en esta sesión.';

  /// Respaldo para una captura sin metadatos de calibración.
  static const intervalUnavailable = 'Intervalo de peso no disponible para esta captura.';

  /// Expresa los límites estimados que acompañan al peso calculado.
  static String weightRange(double lowerKg, double upperKg) =>
      'Rango: ${lowerKg.toStringAsFixed(1)}–${upperKg.toStringAsFixed(1)} kg';

  /// Regreso a cámara.
  static const retry = 'Repetir foto';

  /// Título de alerta ante una captura no utilizable.
  static const rejected = 'Repetí la foto';

  /// Explicación del desenfoque.
  static const blurry =
      'La zona del animal no tiene suficiente nitidez. Mantené el celular firme y esperá a que el bovino esté quieto.';

  /// Advertencia no bloqueante mientras el umbral no esté calibrado en campo.
  static const sharpnessWarning =
      'El control automático detectó posible desenfoque. Ampliá la imagen y confirmá visualmente la nitidez.';

  /// Advertencia de encuadre reservada para un futuro detector del animal.
  static const framingWarning = 'Revisá que el animal esté completo y de perfil antes de usar la foto.';

  /// Advertencia no bloqueante para una exposición extrema.
  static const exposureWarning =
      'La foto parece demasiado oscura o clara. Revisá si el animal se distingue correctamente.';

  /// Explicación del control geométrico.
  static const framing =
      'No hay suficiente detalle distribuido dentro de la guía o la foto no es horizontal. Incluí al animal completo y reintentá.';

  /// Explicación de exposición inválida.
  static const exposure = 'La foto está demasiado oscura o clara. Buscá iluminación uniforme y reintentá.';

  /// Resolución mínima necesaria para continuar con el procesamiento.
  static const resolution = 'La foto tiene una resolución insuficiente. Repetí la captura.';

  /// Error recuperable de cámara, permisos o dispositivo ausente.
  static const cameraError = 'No pudimos abrir la cámara trasera. Revisá el permiso de cámara en Ajustes y reintentá.';

  /// Error al tomar o decodificar una fotografía.
  static const processingError = 'No pudimos procesar la foto. Reintentá la captura.';

  /// Progreso del análisis offline.
  static const processing = 'Analizando la foto…';

  /// Confirmación humana de nitidez.
  static const sharpnessConfirmation = 'La fotografía está nítida.';

  /// Confirmación humana del encuadre completo.
  static const completeAnimalConfirmation = 'El bovino aparece completo dentro de la imagen.';

  /// Confirmación humana mientras falta el detector de perfil.
  static const lateralConfirmation = 'Hay un solo bovino y está de perfil.';

  /// Revisión previa a cualquier uso posterior de la captura.
  static const review = 'Revisá la captura';

  /// Título de la tarjeta que agrupa la validación humana.
  static const manualReviewTitle = 'Control de la captura';

  /// Estado que evita prometer una persistencia todavía no implementada.
  static const draftReady = 'Captura revisada en esta sesión. Todavía no se guarda ni se estima el peso.';

  /// Falta al menos una confirmación manual.
  static const confirmManualReview = 'Completá los tres controles o repetí la foto.';
}
