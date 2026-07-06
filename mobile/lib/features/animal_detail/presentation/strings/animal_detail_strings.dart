import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Textos de la pantalla de detalle de animal.
class AnimalDetailStrings {
  const AnimalDetailStrings._();

  /// Titulo del app bar.
  static const pageTitle = 'Detalle de animal';

  /// Etiqueta del identificador principal.
  static const animalIdLabel = 'Caravana / ID';

  /// Etiqueta de ubicacion actual.
  static const currentLocationLabel = 'Ubicación actual';

  /// Etiqueta de raza.
  static const breedLabel = 'Raza';

  /// Etiqueta de sexo.
  static const sexLabel = 'Sexo';

  /// Sexo macho.
  static const sexMale = 'Macho';

  /// Sexo hembra.
  static const sexFemale = 'Hembra';

  /// Etiqueta de categoria.
  static const categoryLabel = 'Categoría';

  ///Etiqueta de Pelaje
  static const coatLabel = 'Pelaje';

  /// Etiqueta de fecha de nacimiento.
  static const birthDateLabel = 'Fecha de Nacimiento';

  /// Etiqueta de edad.
  static const ageLabel = 'Edad';

  /// Sufijo de meses.
  static const monthsSuffix = 'meses';

  /// Sufijo de años.
  static const yearsSuffix = 'años';

  /// Etiqueta de ultimo peso.
  static const lastWeightLabel = 'Último peso';

  /// Etiqueta de fuente del ultimo peso.
  static const lastWeightSourceLabel = 'Fuente último peso';

  /// Etiqueta de observaciones.
  static const observationsLabel = 'Observaciones';

  /// Metodo de pesaje manual.
  static const manualWeighingMethod = 'Manual';

  /// Metodo de pesaje por balanza bluetooth.
  static const bluetoothWeighingMethod = 'Balanza Bluetooth';

  /// Metodo de pesaje por IA.
  static const aiWeighingMethod = 'Estimación por IA';

  /// Titulo del grafico de peso.
  static const weightChartTitle = 'Evolución de Peso';

  /// Titulo del historial.
  static const eventHistoryTitle = 'Historial de Eventos';

  /// Titulo del evento de nacimiento.
  static const birthEventTitle = 'Nacimiento';

  /// Descripcion del evento de nacimiento.
  static const birthEventDescription = 'Fecha de nacimiento registrada.';

  /// Estado pendiente de sincronizacion.
  static const pendingSyncStatus = 'Pendiente de sincronización';

  /// Estado sincronizado.
  static const synchronizedSyncStatus = 'Sincronizado con backend';

  /// Estado rechazado por backend.
  static const rejectedSyncStatus = 'Rechazado por backend';

  /// Etiqueta de ultima lectura.
  static const lastReadingLabel = 'Última lectura:';

  /// Mensaje de error de carga.
  static const loadError = 'Error al cargar la información del animal.';

  /// Valor mostrado cuando el backend/cache aun no tiene un dato.
  static const noDataValue = 'Sin dato';

  /// Etiquetas de meses del grafico de peso.
  static const weightChartMonthLabels = <int, String>{
    1: 'Ene',
    2: 'Feb',
    3: 'Mar',
    4: 'Abr',
    5: 'May',
    6: 'Jun',
  };

  /// Puntos mock del grafico de peso.
  static const weightChartPoints = <AppLineChartPoint>[
    AppLineChartPoint(x: 1, y: 250),
    AppLineChartPoint(x: 2, y: 280),
    AppLineChartPoint(x: 3, y: 310),
    AppLineChartPoint(x: 4, y: 340),
    AppLineChartPoint(x: 5, y: 390),
    AppLineChartPoint(x: 6, y: 410),
  ];
}
