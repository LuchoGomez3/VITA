import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Textos y datos mock de la pantalla de detalle de animal.
class AnimalDetailStrings {
  const AnimalDetailStrings._();

  /// Titulo del app bar.
  static const pageTitle = 'Detalle de animal';

  /// Etiqueta del identificador principal.
  static const animalIdLabel = 'Caravana / ID';

  /// Potrero mock actual.
  static const currentLot = 'Potrero 3';

  /// Etiqueta de ubicacion actual.
  static const currentLocationLabel = 'Ubicación actual';

  /// Etiqueta de raza.
  static const breedLabel = 'Raza';

  /// Raza mock.
  static const breedValue = 'Brahman';

  /// Etiqueta de sexo.
  static const sexLabel = 'Sexo';

  /// Sexo mock.
  static const sexValue = 'Macho';

  /// Etiqueta de categoria.
  static const categoryLabel = 'Categoría';

  /// Categoria mock.
  static const categoryValue = 'Novillo';

  /// Etiqueta de fecha de nacimiento.
  static const birthDateLabel = 'Fecha de Nacimiento';

  /// Fecha de nacimiento mock.
  static const birthDateValue = '12/11/2024';

  /// Etiqueta de edad.
  static const ageLabel = 'Edad';

  /// Edad mock.
  static const ageValue = '19 meses';

  /// Etiqueta de ultimo peso.
  static const lastWeightLabel = 'Último peso';

  /// Ultimo peso mock.
  static const lastWeightValue = '410 kg';

  /// Etiqueta de fuente del ultimo peso.
  static const lastWeightSourceLabel = 'Fuente último peso';

  /// Fuente mock del ultimo peso.
  static const lastWeightSourceValue = 'Estimación por IA';

  /// Titulo del grafico de peso.
  static const weightChartTitle = 'Evolución de Peso';

  /// Titulo del historial.
  static const eventHistoryTitle = 'Historial de Eventos';

  /// Texto de eventos pendientes de sincronizacion.
  static const pendingSyncEvents = '2 eventos pendientes de\nsincronización';

  /// Etiqueta de ultima lectura.
  static const lastReadingLabel = 'Última lectura:';

  /// Fecha mock de ultima lectura.
  static const lastReadingDate = '10/06/2026';

  /// Mensaje de error de carga.
  static const loadError = 'Error al cargar la información del animal.';

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

  /// Eventos mock del historial de trazabilidad.
  static const eventHistoryItems = <AppTimelineItem>[
    AppTimelineItem(
      date: '10/06/2026',
      title: 'Pesaje registrado',
      description: 'Peso: 410 kg (Estimación por IA).',
      icon: Icons.monitor_weight_outlined,
      iconColor: Colors.blue,
    ),
    AppTimelineItem(
      date: '15/03/2026',
      title: 'Vacunación SENASA',
      description: 'Campaña Antiaftosa y Antibrucélica.',
      icon: Icons.vaccines_outlined,
      iconColor: Colors.red,
    ),
    AppTimelineItem(
      date: '01/02/2026',
      title: 'Movimiento interno',
      description: 'Traslado desde Potrero 1 a Potrero 3.',
      icon: Icons.sync_alt_outlined,
      iconColor: Colors.orange,
    ),
    AppTimelineItem(
      date: '12/11/2024',
      title: 'Alta de animal',
      description: 'Registro inicial en el sistema. Nacimiento.',
      icon: Icons.add_circle_outline,
      iconColor: Colors.green,
    ),
  ];
}
