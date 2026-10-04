import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';

/// Textos visibles del flujo de registro de ventas de hacienda.
abstract final class LivestockSaleStrings {
  /// Titulo comun del flujo.
  static const title = 'Registro de Venta';

  /// Subtitulo del primer paso.
  static const animalSelectionStep = 'Paso 1 de 3 · Animales vendidos';

  /// Subtitulo del segundo paso.
  static const operationDataStep = 'Paso 2 de 3 · Datos de la operación';

  /// Subtitulo del resumen.
  static const reviewStep = 'Paso 3 de 3 · Resumen de la operación';

  /// Texto temporal del contenido que se implementara en el siguiente bloque.
  static const pendingScreenContent = 'Contenido de la pantalla pendiente';

  /// Titulo principal de la seleccion de animales.
  static const animalSelectionTitle = 'Seleccioná los animales vendidos';

  /// Explicacion del origen offline de la seleccion.
  static const animalSelectionDescription = 'Buscá cada animal por su caravana RFID guardada en el dispositivo.';

  /// Titulo del bloque de ingreso manual.
  static const addAnimalTitle = 'Agregar animal';

  /// Accion que abre la lectura mediante baston Bluetooth HID.
  static const scanWithRfidReader = 'Leer con bastón RFID';

  /// Encabezado de la alternativa de ingreso manual.
  static const manualRfidTitle = 'O ingresá la caravana manualmente';

  /// Label del campo RFID.
  static const rfidFieldLabel = 'Nº de caravana RFID';

  /// Placeholder del campo RFID.
  static const rfidFieldHint = 'Ingresá los 15 dígitos';

  /// Accion para incorporar el animal encontrado.
  static const addAnimal = 'Agregar';

  /// Accion mientras se consulta el inventario local.
  static const addingAnimal = 'Buscando...';

  /// Encabezado de la lista seleccionada.
  static const selectedAnimals = 'Animales seleccionados';

  /// Titulo cuando la seleccion esta vacia.
  static const emptySelectionTitle = 'Todavía no agregaste animales';

  /// Ayuda mostrada antes de la primera seleccion.
  static const emptySelectionDescription = 'Los animales que agregues aparecerán en esta lista.';

  /// Tooltip para quitar un animal.
  static const removeAnimal = 'Quitar animal';

  /// Valor alternativo para animales sin categoria local.
  static const unavailableCategory = 'Sin categoría';

  /// Valor alternativo para animales sin lote local.
  static const unavailableLot = 'Sin lote';

  /// Cantidad seleccionada para el contador visual.
  static String selectedAnimalCount(int count) => '$count';

  /// RFID visible en una tarjeta seleccionada.
  static String animalRfid(String value) => 'RFID $value';

  /// Accion para volver al paso anterior.
  static const back = 'Atrás';

  /// Accion para avanzar al siguiente paso.
  static const next = 'Siguiente';

  /// Accion final del resumen.
  static const confirmSale = 'Confirmar venta';

  /// Mensaje cuando la ruta no identifica un establecimiento.
  static const requiredEstablishment = 'Seleccioná un establecimiento para registrar la venta.';

  /// Error del primer paso sin animales.
  static const requiredAnimals = 'Agregá al menos un animal antes de continuar.';

  /// Error para numeros vacios, invalidos o con demasiados decimales.
  static const invalidNumber = 'Revisá los importes y cantidades ingresados.';

  /// Traduce errores funcionales de la venta a mensajes para el formulario.
  static String saleError(LivestockSaleError error) => switch (error) {
    LivestockSaleError.requiredEstablishment => requiredEstablishment,
    LivestockSaleError.futureOperationDate => 'La fecha de operación no puede ser futura.',
    LivestockSaleError.requiredBuyerName => 'Ingresá el nombre o la razón social del comprador.',
    LivestockSaleError.requiredBuyerLastName => 'Ingresá el apellido del comprador.',
    LivestockSaleError.invalidBuyerName => 'El nombre del comprador admite solamente letras.',
    LivestockSaleError.invalidBuyerLastName => 'El apellido del comprador admite solamente letras.',
    LivestockSaleError.companyWithLastName => 'Una empresa debe registrarse mediante su razón social.',
    LivestockSaleError.invalidDteNumber => 'Ingresá un número de DTe válido.',
    LivestockSaleError.invalidAnimals => requiredAnimals,
    LivestockSaleError.invalidTotalAmount => 'Ingresá un monto total válido.',
    LivestockSaleError.bulkWithUnitValues => 'La venta al bulto no utiliza peso ni precio por kilo.',
    LivestockSaleError.invalidTotalWeight => 'Ingresá un peso total válido.',
    LivestockSaleError.invalidPricePerKg => 'Ingresá un precio por kilo válido.',
    LivestockSaleError.inconsistentCalculatedTotal => 'El total no coincide con el peso y el precio por kilo.',
    LivestockSaleError.requiredInitialPayment => 'Ingresá los datos del cobro inicial.',
    LivestockSaleError.pendingWithInitialPayment =>
      'Una venta a cobrar posteriormente no debe registrar un cobro inicial.',
    LivestockSaleError.invalidInitialPaymentAmount => 'Revisá el monto que se cobra ahora.',
    LivestockSaleError.futureInitialPaymentDate => 'La fecha de cobro no puede ser futura.',
    LivestockSaleError.invalidStoredData => 'No se pudieron interpretar los datos guardados.',
    LivestockSaleError.animalNotFound => 'Uno de los animales ya no está disponible.',
    LivestockSaleError.differentEstablishment => 'Uno de los animales pertenece a otro establecimiento.',
    LivestockSaleError.animalNotActive => 'Uno de los animales ya no está activo.',
    LivestockSaleError.localSave => 'No se pudo guardar la venta en el dispositivo.',
  };

  /// Traduce errores de lectura y seleccion de animales.
  static String selectionError(LivestockSaleSelectionError error) => switch (error) {
    LivestockSaleSelectionError.invalidRfid => 'Ingresá una caravana RFID válida.',
    LivestockSaleSelectionError.animalNotFound => 'No se encontró el animal en el dispositivo.',
    LivestockSaleSelectionError.differentEstablishment => 'El animal pertenece a otro establecimiento.',
    LivestockSaleSelectionError.animalSold => 'El animal ya figura como vendido.',
    LivestockSaleSelectionError.animalDead => 'El animal figura como fallecido.',
    LivestockSaleSelectionError.animalRemoved => 'El animal fue dado de baja.',
    LivestockSaleSelectionError.animalStatusUnknown => 'No se pudo comprobar el estado productivo del animal.',
    LivestockSaleSelectionError.duplicateAnimal => 'El animal ya está incluido en la venta.',
    LivestockSaleSelectionError.localRead => 'No se pudo consultar el inventario guardado en el dispositivo.',
  };
}
