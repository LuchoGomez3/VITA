import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Fotos privadas del dispositivo compartidas por pesaje y detalle animal.
///
/// No participa de Brick ni de la sincronización: conserva una foto por animal
/// dentro de los datos de la app, separados también por establecimiento.
class AnimalPhotoStore {
  /// Permite sustituir el directorio privado por uno temporal en las pruebas.
  const AnimalPhotoStore({
    Future<Directory> Function() directoryProvider = getApplicationSupportDirectory,
    AssetBundle? assetBundle,
  }) : _directoryProvider = directoryProvider,
       _assetBundle = assetBundle;

  final Future<Directory> Function() _directoryProvider;
  final AssetBundle? _assetBundle;

  /// Busca una foto incluida en la app cuyo nombre coincide con la caravana.
  ///
  /// Se eliminan espacios del número, pero se conservan los ceros iniciales.
  /// Solo busca en la carpeta acordada y admite JPG, JPEG, PNG y WebP.
  Future<String?> findBundledPhoto(String visualTag) async {
    final tag = visualTag.replaceAll(RegExp(r'\s+'), '');
    if (tag.isEmpty) return null;
    final manifest = await AssetManifest.loadFromAssetBundle(_assetBundle ?? rootBundle);
    final assets = manifest.listAssets().toSet();
    for (final extension in ['jpg', 'jpeg', 'png', 'webp']) {
      final path = 'assets/images/animal_photos/$tag.$extension';
      if (assets.contains(path)) return path;
    }
    return null;
  }

  /// Copia una captura al almacenamiento privado y reemplaza la foto anterior.
  ///
  /// La rama de pesaje debe esperar esta copia antes de eliminar la captura
  /// temporal. Si falla, el error se propaga para que el flujo pueda informarlo.
  Future<String> savePhoto({
    required String establishmentId,
    required String animalId,
    required String sourcePath,
  }) async {
    final destination = await _photoFile(establishmentId, animalId);
    await destination.parent.create(recursive: true);
    await File(sourcePath).copy(destination.path);
    // Evita mostrar la foto anterior desde memoria después de reemplazarla.
    await FileImage(destination).evict();
    return destination.path;
  }

  /// Guarda el JPEG revisado por pesaje IA sin crear un archivo de cámara.
  ///
  /// Escribe primero en un archivo auxiliar para conservar la foto anterior si
  /// la escritura falla. La ruta coincide con la que consulta visualizar animal.
  Future<String> savePhotoBytes({
    required String establishmentId,
    required String animalId,
    required Uint8List jpegBytes,
  }) async {
    final destination = await _photoFile(establishmentId, animalId);
    await destination.parent.create(recursive: true);
    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsBytes(jpegBytes, flush: true);
    await temporary.rename(destination.path);
    await FileImage(destination).evict();
    return destination.path;
  }

  /// Devuelve la ruta local o null cuando no hay foto o no se puede leer.
  ///
  /// La foto es opcional: un fallo de acceso al disco no invalida la ficha.
  Future<String?> findPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    try {
      final file = await _photoFile(establishmentId, animalId);
      return file.existsSync() ? file.path : null;
    } on FileSystemException {
      return null;
    }
  }

  /// Codifica los IDs para que cada uno ocupe un único segmento de la ruta.
  Future<File> _photoFile(String establishmentId, String animalId) async {
    final directory = await _directoryProvider();
    final establishment = Uri.encodeComponent(establishmentId);
    final animal = Uri.encodeComponent(animalId);
    return File('${directory.path}/animal_photos/$establishment/$animal/photo');
  }
}
