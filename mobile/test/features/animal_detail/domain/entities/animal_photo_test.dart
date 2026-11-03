import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';

void main() {
  test('has value equality and immutable bytes', () {
    final source = Uint8List.fromList([1, 2, 3]);
    final photo = AnimalPhoto.fromBytes(source);

    expect(photo, AnimalPhoto.fromBytes([1, 2, 3]));
    expect(photo.bytes, isA<Uint8List>());
    expect(() => photo.bytes.add(4), throwsUnsupportedError);
    expect(() => photo.bytes[0] = 9, throwsUnsupportedError);

    source[0] = 9;
    expect(photo.bytes, [1, 2, 3]);
  });
}
