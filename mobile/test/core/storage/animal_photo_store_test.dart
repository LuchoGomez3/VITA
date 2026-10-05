import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late AnimalPhotoStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('animal-photo-test-');
    store = AnimalPhotoStore(directoryProvider: () async => directory);
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('copies the capture so it survives removal of the temporary source', () async {
    // Arrange: bytes sintéticos; este test verifica persistencia, no decodificación.
    final capture = await File('${directory.path}/capture').writeAsBytes([1, 2, 3]);

    // Act: se guarda y se elimina el archivo temporal original.
    await store.savePhoto(establishmentId: 'farm', animalId: 'animal', sourcePath: capture.path);
    await capture.delete();
    final path = await store.findPhoto(establishmentId: 'farm', animalId: 'animal');

    // Assert: otra instancia puede recuperar la copia privada sin red.
    expect(path, isNotNull);
    expect(await File(path!).readAsBytes(), [1, 2, 3]);
    final reopened = AnimalPhotoStore(directoryProvider: () async => directory);
    expect(await reopened.findPhoto(establishmentId: 'farm', animalId: 'animal'), path);
    expect(await store.findPhoto(establishmentId: 'other-farm', animalId: 'animal'), isNull);
    expect(await store.findPhoto(establishmentId: 'farm', animalId: 'other-animal'), isNull);
  });

  test('replaces the previous photo and returns null after the private file is removed', () async {
    final capture = await File('${directory.path}/capture').writeAsBytes([1]);
    final path = await store.savePhoto(establishmentId: 'farm', animalId: 'animal', sourcePath: capture.path);

    await capture.writeAsBytes([2]);
    await store.savePhoto(establishmentId: 'farm', animalId: 'animal', sourcePath: capture.path);

    expect(await File(path).readAsBytes(), [2]);
    await File(path).delete();
    expect(await store.findPhoto(establishmentId: 'farm', animalId: 'animal'), isNull);
  });

  test('persiste bytes de pesaje y reemplaza la foto que consulta la ficha', () async {
    final firstPath = await store.savePhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
      jpegBytes: Uint8List.fromList([1, 2, 3]),
    );
    await store.savePhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
      jpegBytes: Uint8List.fromList([4, 5]),
    );
    final reopened = AnimalPhotoStore(directoryProvider: () async => directory);
    final path = await reopened.findPhoto(establishmentId: 'farm', animalId: 'animal');
    expect(path, firstPath);
    expect(await File(path!).readAsBytes(), [4, 5]);
    expect(await reopened.findPhoto(establishmentId: 'other-farm', animalId: 'animal'), isNull);
  });

  test('matches the visual tag without spaces and preserves leading zeroes', () async {
    final bundledStore = AnimalPhotoStore(
      assetBundle: _PhotoAssetBundle([
        'assets/images/animal_photos/0031295.png',
        'assets/images/animal_photos/0031295.jpg',
        'assets/images/other.jpg',
      ]),
    );

    expect(await bundledStore.findBundledPhoto('003 1295'), 'assets/images/animal_photos/0031295.jpg');
    expect(await bundledStore.findBundledPhoto('31295'), isNull);
    expect(await bundledStore.findBundledPhoto('unknown'), isNull);
    expect(await bundledStore.findBundledPhoto('  '), isNull);
  });
}

/// Manifiesto sintético para comprobar búsquedas sin incluir fotos en las pruebas.
class _PhotoAssetBundle extends CachingAssetBundle {
  _PhotoAssetBundle(this.paths);

  final List<String> paths;

  @override
  Future<ByteData> load(String key) async {
    return const StandardMessageCodec().encodeMessage({
      for (final path in paths)
        path: [
          {'asset': path},
        ],
    })!;
  }
}
