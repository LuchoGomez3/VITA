import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_photo.freezed.dart';

/// Foto local de un animal representada sin detalles del filesystem.
@freezed
sealed class AnimalPhoto with _$AnimalPhoto {
  const AnimalPhoto._();

  /// Representación inmutable utilizada por el código generado de Freezed.
  const factory AnimalPhoto.immutable({
    required AnimalPhotoBytes encodedBytes,
  }) = _AnimalPhoto;

  /// Crea una foto y copia sus bytes para mantener el valor inmutable.
  factory AnimalPhoto.fromBytes(List<int> bytes) => AnimalPhoto.immutable(encodedBytes: AnimalPhotoBytes(bytes));

  /// Bytes codificados de la imagen.
  Uint8List get bytes => encodedBytes.values;
}

/// Colección de bytes con copia defensiva y semántica de valor.
@immutable
final class AnimalPhotoBytes {
  /// Copia [source] para evitar mutaciones a través de la lista original.
  AnimalPhotoBytes(List<int> source) : values = Uint8List.fromList(source).asUnmodifiableView();

  /// Valores inmutables de la colección.
  final Uint8List values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimalPhotoBytes || values.length != other.values.length) {
      return false;
    }
    for (var index = 0; index < values.length; index++) {
      if (values[index] != other.values[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);
}
