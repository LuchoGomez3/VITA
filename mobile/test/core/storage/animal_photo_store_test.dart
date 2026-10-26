import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';

void main() {
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
    final bytes = await store.readPhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
    );

    expect(bytes, [1, 2, 3]);
    final reopened = AnimalPhotoStore(directoryProvider: () async => directory);
    expect(
      await reopened.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      [1, 2, 3],
    );
    expect(
      await store.readPhotoBytes(
        establishmentId: 'other-farm',
        animalId: 'animal',
      ),
      isNull,
    );
    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'other-animal',
      ),
      isNull,
    );
  });

  test('replaces the previous photo and returns null after removal', () async {
    final capture = await File('${directory.path}/capture').writeAsBytes([1]);
    await store.savePhoto(
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

    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      [2],
    );
    await File(
      '${directory.path}/animal_photos/farm/animal/photo',
    ).delete();
    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      isNull,
    );
  });

  test('stores in-memory JPEG bytes in the same private location', () async {
    await store.savePhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
      jpegBytes: Uint8List.fromList([4, 5, 6]),
    );

    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      [4, 5, 6],
    );
  });

  test('keeps the previous photo when writing the replacement fails', () async {
    await store.savePhotoBytes(
      establishmentId: 'farm',
      animalId: 'animal',
      jpegBytes: Uint8List.fromList([1, 2, 3]),
    );

    await expectLater(
      store.savePhoto(
        establishmentId: 'farm',
        animalId: 'animal',
        sourcePath: '${directory.path}/missing-capture',
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      [1, 2, 3],
    );
  });

  test('recovers the previous photo after an interrupted replacement', () async {
    final photoDirectory = Directory(
      '${directory.path}/animal_photos/farm/animal',
    );
    await photoDirectory.create(recursive: true);
    await File('${photoDirectory.path}/photo.backup').writeAsBytes([7, 8, 9]);
    await File('${photoDirectory.path}/photo.tmp').writeAsBytes([4]);

    expect(
      await store.readPhotoBytes(
        establishmentId: 'farm',
        animalId: 'animal',
      ),
      [7, 8, 9],
    );
    expect(File('${photoDirectory.path}/photo').existsSync(), isTrue);
    expect(File('${photoDirectory.path}/photo.backup').existsSync(), isFalse);
    expect(File('${photoDirectory.path}/photo.tmp').existsSync(), isFalse);
  });
}
