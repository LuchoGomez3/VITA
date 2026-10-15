import 'dart:io';
import 'dart:typed_data';

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
    final capture = await File('${directory.path}/capture').writeAsBytes([1, 2, 3]);

    await store.savePhoto(
      establishmentId: 'farm',
      animalId: 'animal',
      sourcePath: capture.path,
    );
    await capture.delete();
    final path = await store.findPhoto(
      establishmentId: 'farm',
      animalId: 'animal',
    );

    expect(path, isNotNull);
    expect(await File(path!).readAsBytes(), [1, 2, 3]);
    final reopened = AnimalPhotoStore(directoryProvider: () async => directory);
    expect(
      await reopened.findPhoto(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      path,
    );
    expect(
      await store.findPhoto(
        establishmentId: 'other-farm',
        animalId: 'animal',
      ),
      isNull,
    );
    expect(
      await store.findPhoto(
        establishmentId: 'farm',
        animalId: 'other-animal',
      ),
      isNull,
    );
  });

  test('replaces the previous photo and returns null after removal', () async {
    final capture = await File('${directory.path}/capture').writeAsBytes([1]);
    final path = await store.savePhoto(
      establishmentId: 'farm',
      animalId: 'animal',
      sourcePath: capture.path,
    );

    await capture.writeAsBytes([2]);
    await store.savePhoto(
      establishmentId: 'farm',
      animalId: 'animal',
      sourcePath: capture.path,
    );

    expect(await File(path).readAsBytes(), [2]);
    await File(path).delete();
    expect(
      await store.findPhoto(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      isNull,
    );
  });

  test('stores in-memory JPEG bytes in the same private location', () async {
    final path = await store.savePhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
      jpegBytes: Uint8List.fromList([4, 5, 6]),
    );

    expect(await File(path).readAsBytes(), [4, 5, 6]);
    expect(
      await store.findPhoto(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      path,
    );
  });
}
