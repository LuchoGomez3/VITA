import 'dart:typed_data';

/// Lee y reemplaza el fondo privado de un establecimiento.
typedef FieldMapPhotoActions = ({
  Future<Uint8List?> Function(String establishmentId) read,
  Future<Uint8List?> Function(String establishmentId) select,
});
