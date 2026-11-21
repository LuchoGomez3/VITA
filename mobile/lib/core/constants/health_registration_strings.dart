/// Textos de la carga y consulta sanitaria.
abstract final class HealthRegistrationStrings {
  /// Acción principal de registro.
  static const register = 'Registrar sanidad';

  /// Apertura de una sesión de manga.
  static const capture = 'Cargar sanidad';

  /// Selector de campo.
  static const establishment = 'Establecimiento';

  /// Selector de práctica.
  static const practice = 'Práctica sanitaria';

  /// Selector de producto.
  static const product = 'Producto';

  /// Dato de administración.
  static const dose = 'Dosis';

  /// Unidad de la dosis.
  static const unit = 'Unidad';

  /// Vía de administración.
  static const route = 'Vía de administración';

  /// Identificador de la partida.
  static const batch = 'Serie o partida (opcional)';

  /// Partida que se muestra al consultar el evento.
  static const recordedBatch = 'Serie o partida';

  /// Fecha de vencimiento del producto.
  static const expiration = 'Vencimiento (opcional)';

  /// Fecha de vencimiento que se muestra al consultar el evento.
  static const recordedExpiration = 'Vencimiento';

  /// Descripción de una observación o lesión.
  static const description = 'Descripción';

  /// Motivo del estudio.
  static const reason = 'Motivo del estudio';

  /// Tipo de muestra que se tomó.
  static const sampleType = 'Tipo de muestra';

  /// Identificador por animal.
  static const sampleReference = 'Referencia de muestra (opcional)';

  /// Persona responsable de la práctica.
  static const responsible = 'Responsable';

  /// Fecha efectiva de la práctica.
  static const date = 'Fecha de aplicación';

  /// Notas adicionales.
  static const notes = 'Observaciones (opcional)';

  /// Confirmación de la selección.
  static const confirm = 'Confirmar registro';

  /// Confirmación durable en SQLite.
  static const saved = 'Guardado en el dispositivo';

  /// Consulta sin registros previos.
  static const emptyHistory = 'Este animal todavía no tiene eventos sanitarios.';

  /// Estado de sincronización.
  static const pending = 'Pendiente de sincronización';

  /// El servidor confirmó el registro.
  static const synchronized = 'Sincronizado';

  /// Estado de sincronización.
  static const rejected = 'Rechazado';

  /// Resultado todavía no disponible.
  static const pendingResult = 'Resultado pendiente';

  /// Acción de carga de resultado.
  static const addResult = 'Cargar resultado';

  /// Acción para corregir un rechazo propio.
  static const correct = 'Corregir registro';

  /// Valor del primer resultado del estudio.
  static const result = 'Resultado del estudio';

  /// Fecha del informe.
  static const resultDate = 'Fecha del resultado';

  /// Acción de guardado del resultado.
  static const saveResult = 'Guardar resultado';

  /// Error de infraestructura local.
  static const failed = 'No se pudo completar la operación. Volvé a intentar.';

  /// Formulario cargado con una selección vacía.
  static const noAnimals = 'No hay animales seleccionados.';

  /// Entrada manual de caravana visual.
  static const visual = 'Caravana visual';

  /// Entrada manual de RFID.
  static const electronic = 'RFID';

  /// Botón para sumar la caravana escrita.
  static const addTag = 'Agregar caravana';

  /// Feedback por animal repetido en la lista.
  static const duplicate = 'Este animal ya está en la selección.';

  /// Se informa la actualización aceptada por otro dispositivo.
  static const resultConflict = 'El resultado ya se había cargado desde otro dispositivo.';

  /// La creación del animal debe corregirse antes de enviar el evento.
  static const animalRegistrationRejected = 'Revisá el alta del animal antes de sincronizar este registro.';

  /// Indica qué dato revisar sin mostrar los códigos técnicos de la API.
  static String? rejectionPrompt({String? animalLabel, String? field}) {
    final label = switch (field?.split('.').last) {
      'practica_id' => practice,
      'producto_id' => product,
      'dosis' => dose,
      'unidad' => unit,
      'via' => route,
      'serie' => recordedBatch,
      'vencimiento' => recordedExpiration,
      'descripcion' => description,
      'tipo_muestra' => sampleType,
      'referencia_muestra' => sampleReference,
      'responsable' => responsible,
      'fecha_aplicacion' => date,
      'resultado' => result,
      'fecha' => resultDate,
      _ => null,
    };
    return switch ((animalLabel, label)) {
      (final animal?, final name?) => 'Revisá el campo «$name» para la caravana $animal.',
      (final animal?, null) => 'Revisá la caravana $animal.',
      (null, final name?) => 'Revisá el campo «$name».',
      (null, null) => null,
    };
  }

  /// Entrada de una caravana con bastón.
  static const scanHint = 'Leé con el bastón RFID o ingresá una caravana.';

  /// Activa el bastón en la sesión de manga.
  static const useReader = 'Leer con bastón';

  /// Abre el ingreso con teclado.
  static const useManual = 'Ingresar caravana manual';

  /// CTA que refresca el catálogo.
  static const refresh = 'Actualizar catálogo';

  /// Cantidad seleccionada antes de guardar.
  static String selected(int count) => count == 1 ? '1 animal seleccionado' : '$count animales seleccionados';

  /// La cuenta no tiene acceso al establecimiento.
  static const unauthorized = 'No tenés acceso a Sanidad en este establecimiento.';

  /// El dispositivo necesita descargar el catálogo.
  static const catalogUnavailable = 'Conectate y sincronizá para descargar el catálogo sanitario.';

  /// La selección pide una práctica o producto que salió del catálogo.
  static const unavailablePractice = 'La práctica o el producto ya no están disponibles.';

  /// Faltan datos obligatorios.
  static const invalidDetails = 'Revisá los datos obligatorios de la práctica.';

  /// La lista no se puede confirmar.
  static const invalidSelection = 'Revisá los animales seleccionados.';

  /// La caravana no identifica un animal disponible.
  static const unavailableAnimal = 'El animal no está disponible en este establecimiento.';

  /// El bastón o campo manual debe entregar un RFID completo.
  static const invalidTag = 'El RFID debe tener 15 dígitos.';

  /// Hay más de una coincidencia local.
  static const ambiguousTag = 'Hay más de un animal con esta caravana.';

  /// El estudio no admite el resultado solicitado.
  static const invalidResult = 'Revisá el resultado o si el estudio todavía admite una carga.';
}
