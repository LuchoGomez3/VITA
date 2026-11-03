import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Qué falta subir de la foto.
enum PendingAvatarChange {
  /// Hay una foto nueva en el celular que la cuenta no tiene.
  upload,

  /// Se quitó la foto en el celular y falta borrarla de la cuenta.
  delete,
}

/// Lo que el celular sabe de la apariencia de un usuario.
typedef StoredProfileAppearance = ({
  String userId,
  String? headerColor,
  bool headerColorPending,
  DateTime? avatarUpdatedAt,
  PendingAvatarChange? avatarPending,
  int avatarVersion,
});

/// Guarda el color y el estado de la foto en el storage seguro, y la foto en
/// la carpeta de documentos de la app.
///
/// Se guarda un solo usuario: si entra otro en el mismo celular, lo anterior
/// se descarta en vez de mostrarle el color o la foto de otra persona.
class ProfileAppearanceLocalDataSource {
  /// Crea el data source.
  const ProfileAppearanceLocalDataSource({
    required SecureStorageService secureStorage,
    required AvatarFileStore files,
  }) : _secureStorage = secureStorage,
       _files = files;

  final SecureStorageService _secureStorage;
  final AvatarFileStore _files;

  /// Estado guardado de [userId], o uno vacío si no hay nada o es de otro.
  Future<StoredProfileAppearance> read(String userId) async {
    final encoded = await _secureStorage.read(SecureStorageKeys.profileAppearance);
    final empty = (
      userId: userId,
      headerColor: null,
      headerColorPending: false,
      avatarUpdatedAt: null,
      avatarPending: null,
      avatarVersion: 0,
    );
    if (encoded == null || encoded.isEmpty) {
      return empty;
    }
    final json = jsonDecode(encoded);
    if (json is! Map<String, dynamic> || json['user_id'] != userId) {
      return empty;
    }
    final updatedAt = json['avatar_updated_at'];
    final pending = json['avatar_pending'];
    return (
      userId: userId,
      headerColor: json['header_color'] as String?,
      headerColorPending: json['header_color_pending'] == true,
      avatarUpdatedAt: updatedAt is String ? DateTime.parse(updatedAt) : null,
      avatarPending: PendingAvatarChange.values.where((value) => value.name == pending).firstOrNull,
      avatarVersion: (json['avatar_version'] as num?)?.toInt() ?? 0,
    );
  }

  /// Reemplaza el estado guardado.
  Future<void> write(StoredProfileAppearance state) {
    return _secureStorage.write(
      key: SecureStorageKeys.profileAppearance,
      value: jsonEncode({
        'user_id': state.userId,
        'header_color': state.headerColor,
        'header_color_pending': state.headerColorPending,
        'avatar_updated_at': state.avatarUpdatedAt?.toUtc().toIso8601String(),
        'avatar_pending': state.avatarPending?.name,
        'avatar_version': state.avatarVersion,
      }),
    );
  }

  /// Ruta de la foto de [userId] si existe.
  Future<String?> avatarPath(String userId) => _files.path(userId);

  /// Bytes de la foto de [userId] (para subirla).
  Future<Uint8List?> readAvatar(String userId) => _files.read(userId);

  /// Guarda [jpeg] como la foto de [userId].
  Future<void> saveAvatar(String userId, Uint8List jpeg) => _files.save(userId, jpeg);

  /// Borra la foto de [userId] del celular.
  Future<void> deleteAvatar(String userId) => _files.delete(userId);
}

/// Archivo de la foto en el celular (separado para poder testear sin disco).
abstract interface class AvatarFileStore {
  /// Ruta del archivo si existe.
  Future<String?> path(String userId);

  /// Contenido del archivo si existe.
  Future<Uint8List?> read(String userId);

  /// Escribe el archivo.
  Future<void> save(String userId, Uint8List bytes);

  /// Borra el archivo si existe.
  Future<void> delete(String userId);
}

/// Guarda la foto en la carpeta de documentos de la app.
///
/// Cada foto nueva lleva un nombre distinto y borra las anteriores: así la
/// pantalla no muestra la foto vieja que quedó en el caché de imágenes.
class DocumentsAvatarFileStore implements AvatarFileStore {
  /// Crea el store.
  const DocumentsAvatarFileStore();

  Future<List<File>> _files(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final prefix = 'avatar_${userId}_';
    return directory.listSync().whereType<File>().where((file) => p.basename(file.path).startsWith(prefix)).toList();
  }

  @override
  Future<String?> path(String userId) async {
    final files = await _files(userId);
    return files.isEmpty ? null : files.first.path;
  }

  @override
  Future<Uint8List?> read(String userId) async {
    final files = await _files(userId);
    return files.isEmpty ? null : files.first.readAsBytes();
  }

  @override
  Future<void> save(String userId, Uint8List bytes) async {
    final previous = await _files(userId);
    final directory = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    await File(p.join(directory.path, 'avatar_${userId}_$stamp.jpg')).writeAsBytes(bytes, flush: true);
    for (final file in previous) {
      await file.delete();
    }
  }

  @override
  Future<void> delete(String userId) async {
    for (final file in await _files(userId)) {
      await file.delete();
    }
  }
}
