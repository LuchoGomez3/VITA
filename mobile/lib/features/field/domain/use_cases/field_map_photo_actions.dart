import 'dart:typed_data';

/// Coordenadas del establecimiento y su contorno geográfico, cuando existe.
typedef FieldMapLocation = ({FieldMapPoint center, List<FieldMapPoint> boundary});

/// Punto geográfico en grados.
typedef FieldMapPoint = ({double latitude, double longitude});

/// Resuelve el fondo del mapa y permite reemplazarlo con una foto privada.
typedef FieldMapPhotoActions = ({
  Future<FieldMapLocation?> Function(String establishmentId) locate,
  Future<Uint8List?> Function(String establishmentId) read,
  Future<Uint8List?> Function(String establishmentId) select,
});
