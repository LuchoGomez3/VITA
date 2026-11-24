import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Guarda una foto de fondo en el dispositivo por usuario y establecimiento.
class FieldMapPhotoRepository {
  /// Permite inyectar la sesión, el directorio y el selector para las pruebas.
  const FieldMapPhotoRepository({
    required String? Function() userId,
    Future<Directory> Function() directory = getApplicationSupportDirectory,
    Future<Uint8List?> Function() pick = _pickFromGallery,
  }) : _userId = userId,
       _directory = directory,
       _pick = pick;

  final String? Function() _userId;
  final Future<Directory> Function() _directory;
  final Future<Uint8List?> Function() _pick;

  /// Devuelve el fondo guardado si hay una sesión y el archivo todavía existe.
  Future<Uint8List?> read(String establishmentId) async {
    final userId = _userId();
    if (userId == null) return null;
    final file = await _file(userId, establishmentId);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    return userId == _userId() ? bytes : null;
  }

  /// Selecciona la imagen y reemplaza la anterior mediante un archivo temporal.
  Future<Uint8List?> select(String establishmentId) async {
    final userId = _userId();
    if (userId == null) return null;
    final bytes = await _pick();
    if (bytes == null || bytes.isEmpty || _userId() != userId) return null;
    final file = await _file(userId, establishmentId);
    await file.parent.create(recursive: true);
    final temporary = await file.parent.createTemp('field-photo-');
    try {
      final pending = await File(path.join(temporary.path, 'image')).writeAsBytes(bytes, flush: true);
      if (_userId() != userId) return null;
      await pending.rename(file.path);
    } finally {
      await temporary.delete(recursive: true);
    }
    return _userId() == userId ? bytes : null;
  }

  Future<File> _file(String userId, String establishmentId) async {
    final root = await _directory();
    String component(String value) => base64Url.encode(utf8.encode(value));
    return File(path.join(root.path, 'field_map_photos', component(userId), component(establishmentId), 'image'));
  }

  static Future<Uint8List?> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
    return image?.readAsBytes();
  }
}
