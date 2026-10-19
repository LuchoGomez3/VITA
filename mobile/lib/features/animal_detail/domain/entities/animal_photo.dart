/// Foto local de un animal representada sin detalles del filesystem.
final class AnimalPhoto {
  /// Crea una foto a partir de sus bytes codificados.
  AnimalPhoto({required Iterable<int> bytes}) : bytes = List<int>.unmodifiable(bytes);

  /// Bytes codificados de la imagen.
  final List<int> bytes;
}
