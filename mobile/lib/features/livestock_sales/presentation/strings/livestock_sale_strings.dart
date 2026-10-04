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

  /// Encabezado del bloque de comprador.
  static const buyerSection = 'COMPRADOR';

  /// Label del canal comercial del comprador.
  static const buyerType = 'Tipo de comprador';

  /// Opcion de comprador frigorifico.
  static const slaughterhouse = 'Frigorífico';

  /// Opcion de comprador mediante remate.
  static const auction = 'Remate';

  /// Opcion de comprador particular.
  static const privateBuyer = 'Particular';

  /// Label para distinguir una persona de una empresa.
  static const buyerKind = 'El comprador es';

  /// Opcion para comprador persona.
  static const person = 'Persona';

  /// Opcion para comprador empresa.
  static const company = 'Empresa';

  /// Label del nombre de una persona.
  static const buyerName = 'Nombre *';

  /// Placeholder del nombre de una persona.
  static const buyerNameHint = 'Ingresá el nombre';

  /// Label del apellido de una persona.
  static const buyerLastName = 'Apellido *';

  /// Placeholder del apellido de una persona.
  static const buyerLastNameHint = 'Ingresá el apellido';

  /// Label de la razon social de una empresa.
  static const businessName = 'Razón social *';

  /// Placeholder de la razon social.
  static const businessNameHint = 'Ingresá la razón social';

  /// Label del documento de transito electronico.
  static const dteNumber = 'Nº DTe *';

  /// Placeholder del documento de transito electronico.
  static const dteNumberHint = '123456789-A';

  /// Ayuda del documento de transito electronico.
  static const dteNumberHelper =
      'Ingresá el número completo, incluido el guion y el verificador';

  /// Encabezado de los datos comerciales.
  static const operationSection = 'DATOS DE LA OPERACIÓN';

  /// Label de la fecha de venta.
  static const operationDate = 'Fecha de operación';

  /// Placeholder de fecha.
  static const dateHint = 'Seleccioná una fecha';

  /// Label de la modalidad de venta.
  static const saleType = 'Tipo de venta';

  /// Venta por un monto total ingresado por el productor.
  static const bulkSale = 'Al bulto';

  /// Venta calculada con peso total y precio unitario.
  static const perKilogramSale = 'Por kilo';

  /// Encabezado de precios.
  static const priceSection = 'PRECIO';

  /// Label del monto de una venta al bulto.
  static const totalAmount = 'Monto total *';

  /// Label del peso comercial ingresado por el productor.
  static const totalWeight = 'Kilos totales de la tropa *';

  /// Label del valor unitario exacto.
  static const pricePerKilogram = 'Precio por kilo *';

  /// Titulo del resultado calculado.
  static const calculatedTotal = 'Monto total (calculado)';

  /// Unidad monetaria.
  static const currency = 'ARS';

  /// Unidad de peso.
  static const kilograms = 'kg';

  /// Unidad del precio por kilo.
  static const currencyPerKilogram = r'$/kg';

  /// Encabezado de la situacion de cobro.
  static const paymentStatusSection = 'ESTADO DE COBRO';

  /// Estado cobrado en su totalidad.
  static const totalPayment = 'Cobro total';

  /// Descripcion del cobro total.
  static const totalPaymentDescription = 'Pago al contado';

  /// Estado cobrado parcialmente.
  static const partialPayment = 'Cobro parcial';

  /// Descripcion del cobro parcial.
  static const partialPaymentDescription = 'Cuotas / señal';

  /// Estado sin cobro inicial.
  static const pendingPayment = 'A cobrar';

  /// Descripcion del cobro posterior.
  static const pendingPaymentDescription = 'Pago posterior';

  /// Label del importe recibido al registrar una venta parcial.
  static const amountToCollectNow = 'Monto a cobrar ahora *';

  /// Label del saldo que queda por cobrar.
  static const pendingBalance = 'Saldo pendiente';

  /// Encabezado del instrumento de cobro.
  static const paymentMethodSection = 'FORMA DE COBRO';

  /// Instrumento efectivo.
  static const cash = 'Efectivo';

  /// Instrumento transferencia bancaria.
  static const bankTransfer = 'Transferencia';

  /// Instrumento cheque.
  static const check = 'Cheque';

  /// Instrumento tarjeta.
  static const card = 'Tarjeta';

  /// Presenta el calculo sin ocultar los valores ingresados.
  static String amountCalculation(String weight, String price) => '$weight kg × \$$price/kg';

  /// Encabezado del comprador en el resumen.
  static const summaryBuyerSection = 'COMPRADOR';

  /// Encabezado de animales en el resumen.
  static const summaryAnimalsSection = 'ANIMALES VENDIDOS';

  /// Encabezado de totales en el resumen.
  static const summaryTotalsSection = 'TOTALES';

  /// Encabezado del cobro en el resumen.
  static const summaryPaymentSection = 'COBRO';

  /// Label compacto del DTe en el resumen.
  static const summaryDte = 'DTe Nº';

  /// Label de cantidad de animales.
  static const animals = 'Animales';

  /// Label del tipo de venta resumido.
  static const summarySaleType = 'Tipo de venta';

  /// Label del peso comercial resumido.
  static const summaryTotalWeight = 'Peso total';

  /// Label del precio unitario resumido.
  static const summaryPricePerKilogram = 'Precio por kilo';

  /// Label del importe final resumido.
  static const summaryTotalAmount = 'Monto total';

  /// Label del estado de cobro.
  static const paymentStatus = 'Estado';

  /// Label del medio de cobro.
  static const paymentMethod = 'Forma de cobro';

  /// Cobro total expresado para el resumen.
  static const totalPaymentSummary = 'Cobro total al momento';

  /// Cobro parcial expresado para el resumen.
  static const partialPaymentSummary = 'Cobro parcial / cuotas';

  /// Cobro pendiente expresado para el resumen.
  static const pendingPaymentSummary = 'A cobrar posteriormente';

  /// Importe recibido al registrar la venta.
  static const collectedNow = 'Cobro al momento';

  /// Importe total que queda por cobrar.
  static const totalToCollect = 'Total a cobrar';

  /// Cantidad de cabezas con pluralizacion.
  static String headCount(int count) => count == 1 ? '1 cabeza' : '$count cabezas';

  /// Accion para desplegar animales que exceden el limite inicial.
  static String showRemainingAnimals(int count) => 'Ver $count animales más';

  /// Accion para volver a la lista resumida.
  static const showFewerAnimals = 'Ver menos';

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

  /// Titulo mostrado despues de guardar la operacion localmente.
  static const successTitle = '¡Venta registrada!';

  /// Aclara que la operacion no depende de conectividad inmediata.
  static const successOfflineMessage = 'La venta quedó guardada en este dispositivo y se sincronizará automáticamente.';

  /// Accion para iniciar un flujo limpio con el mismo establecimiento.
  static const registerAnotherSale = 'Registrar otra venta';

  /// Accion para abandonar el flujo finalizado.
  static const backHome = 'Volver al inicio';

  /// Explica cuantas bajas de stock produjo la venta.
  static String soldAnimalCount(int count) =>
      count == 1 ? '1 animal fue dado de baja del stock.' : '$count animales fueron dados de baja del stock.';

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
