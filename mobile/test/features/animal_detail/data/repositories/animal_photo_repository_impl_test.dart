import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_photo_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('AnimalPhotoRepositoryImpl', () {
    test('returns photo bytes without exposing the local path', () async {
      final store = _FakeAnimalPhotoStore(bytes: Uint8List.fromList([1, 2, 3]));
      final repository = AnimalPhotoRepositoryImpl(photoStore: store);

      final result = await repository.getPhoto(
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
      );

      expect(result, isA<Success<AnimalPhoto?>>());
      final photo = (result as Success<AnimalPhoto?>).data;
      expect(photo?.bytes, [1, 2, 3]);
      expect(store.establishmentId, 'establishment-id');
      expect(store.animalId, 'animal-id');
    });

    test('returns an absent photo when the platform directory is unavailable', () async {
      final repository = AnimalPhotoRepositoryImpl(
        photoStore: AnimalPhotoStore(
          directoryProvider: () async => throw MissingPlatformDirectoryException(
            'Application support directory unavailable',
          ),
        ),
      );

      final result = await repository.getPhoto(
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
      );

      expect(result, const Result<AnimalPhoto?>.success(null));
    });

    test('returns an absent photo when the filesystem read fails', () async {
      final repository = AnimalPhotoRepositoryImpl(
        photoStore: _FakeAnimalPhotoStore(
          error: const FileSystemException('Read failed'),
        ),
      );

      final result = await repository.getPhoto(
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
      );

      expect(result, const Result<AnimalPhoto?>.success(null));
    });
  });
}

class _FakeAnimalPhotoStore extends AnimalPhotoStore {
  _FakeAnimalPhotoStore({this.bytes, this.error});

  final Uint8List? bytes;
  final FileSystemException? error;
  String? establishmentId;
  String? animalId;

  @override
  Future<Uint8List?> readPhotoBytes({
    required String establishmentId,
    required String animalId,
  }) async {
    this.establishmentId = establishmentId;
    this.animalId = animalId;
    final readError = error;
    if (readError != null) throw readError;
    return bytes;
  }
}
