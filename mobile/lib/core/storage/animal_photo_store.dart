import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Fotos privadas del dispositivo compartidas por pesaje y detalle animal.
///
/// No participa de Brick ni de la sincronización: conserva una foto por animal
/// dentro de los datos de la app, separados también por establecimiento.
class AnimalPhotoStore {
  /// Permite sustituir el directorio privado por uno temporal en las pruebas.
  const AnimalPhotoStore({
    Future<Directory> Function() directoryProvider = getApplicationSupportDirectory,
  }) : _directoryProvider = directoryProvider;

  final Future<Directory> Function() _directoryProvider;

  /// Copia una captura al almacenamiento privado y reemplaza la foto anterior.
  ///
  /// La rama de pesaje debe esperar esta copia antes de eliminar la captura
  /// temporal. Si falla, el error se propaga para que el flujo pueda informarlo.
  Future<void> savePhoto({
    required String establishmentId,
    required String animalId,
    required String sourcePath,
  }) async {
    final destination = await _photoFile(establishmentId, animalId);
    await destination.parent.create(recursive: true);
    await _writeAtomically(
      destination,
      (temporary) => File(sourcePath).copy(temporary.path),
    );
  }

  /// Guarda bytes JPEG cuando la captura no existe como archivo temporal.
  ///
  /// La ruta coincide con la que consulta el detalle y queda fuera de Brick y
  /// de la cola de sincronización.
  Future<void> savePhotoBytes({
    required String establishmentId,
    required String animalId,
    required Uint8List jpegBytes,
  }) async {
    final destination = await _photoFile(establishmentId, animalId);
    await destination.parent.create(recursive: true);
    await _writeAtomically(
      destination,
      (temporary) => temporary.writeAsBytes(jpegBytes, flush: true),
    );
  }

  /// Lee los bytes de la foto o devuelve null cuando no existe.
  Future<Uint8List?> readPhotoBytes({
    required String establishmentId,
    required String animalId,
  }) async {
    final file = await _photoFile(establishmentId, animalId);
    await _recoverInterruptedReplacement(file);
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  Future<void> _writeAtomically(
    File destination,
    Future<Object> Function(File temporary) writeTemporary,
  ) async {
    await _recoverInterruptedReplacement(destination);
    final temporary = File('${destination.path}.tmp');
    final backup = File('${destination.path}.backup');
    if (temporary.existsSync()) await temporary.delete();
    await writeTemporary(temporary);

    var previousPhotoMoved = false;
    try {
      if (destination.existsSync()) {
        await destination.rename(backup.path);
        previousPhotoMoved = true;
      }
      await temporary.rename(destination.path);
      if (previousPhotoMoved && backup.existsSync()) await backup.delete();
    } on Object catch (error, stackTrace) {
      if (temporary.existsSync()) await temporary.delete();
      if (previousPhotoMoved && !destination.existsSync() && backup.existsSync()) {
        await backup.rename(destination.path);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _recoverInterruptedReplacement(File destination) async {
    final temporary = File('${destination.path}.tmp');
    final backup = File('${destination.path}.backup');
    if (destination.existsSync()) {
      if (backup.existsSync()) await backup.delete();
    } else if (backup.existsSync()) {
      await backup.rename(destination.path);
    }
    if (temporary.existsSync()) await temporary.delete();
  }

  /// Codifica los IDs para que cada uno ocupe un único segmento de la ruta.
  Future<File> _photoFile(String establishmentId, String animalId) async {
    final directory = await _directoryProvider();
    final establishment = Uri.encodeComponent(establishmentId);
    final animal = Uri.encodeComponent(animalId);
    return File('${directory.path}/animal_photos/$establishment/$animal/photo');
  }
}
