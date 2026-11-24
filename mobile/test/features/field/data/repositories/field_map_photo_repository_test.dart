import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/data/repositories/field_map_photo_repository.dart';

void main() {
  test('guarda el fondo por usuario y establecimiento, y conserva la imagen al cancelar', () async {
    final directory = await Directory.systemTemp.createTemp('vita-field-photo-');
    addTearDown(() => directory.delete(recursive: true));
    var user = 'user-a';
    Uint8List? selection = Uint8List.fromList([1, 2, 3]);
    final photos = FieldMapPhotoRepository(
      userId: () => user,
      directory: () async => directory,
      pick: () async => selection,
    );

    expect(await photos.read('field-a'), isNull);
    await photos.select('field-a');
    expect(await photos.read('field-b'), isNull);
    user = 'user-b';
    expect(await photos.read('field-a'), isNull);
    user = 'user-a';

    selection = null;
    expect(await photos.select('field-a'), isNull);
    expect(await photos.read('field-a'), [1, 2, 3]);
    selection = Uint8List.fromList([4, 5, 6]);
    await photos.select('field-a');
    expect(await photos.read('field-a'), [4, 5, 6]);
  });
}
