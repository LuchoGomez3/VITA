import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Presenta la foto completa en una superficie consistente con las tarjetas.
class AnimalDetailPhoto extends StatelessWidget {
  /// Crea la foto desde una captura guardada en los datos privados de la app.
  const AnimalDetailPhoto({required this.photo, required this.contentBuilder, super.key});

  /// Contiene los bytes resueltos por el caso de uso, si existe una foto.
  final AnimalPhoto? photo;

  /// Construye el espacio de foto con una imagen válida o con null para mostrar
  /// el placeholder de la pestaña General.
  final Widget Function(Widget? photo) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final localPhoto = photo;
    if (localPhoto == null) return contentBuilder(null);
    final cacheWidth = (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).ceil();

    return Image.memory(
      localPhoto.bytes,
      cacheWidth: cacheWidth,
      fit: BoxFit.cover,
      semanticLabel: AnimalDetailStrings.animalPhotoLabel,
      // La proporción se aplica después de decodificar para no reservar espacio
      // cuando falta el archivo o la imagen está dañada.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null && !wasSynchronouslyLoaded) return contentBuilder(null);
        return contentBuilder(_PhotoSurface(child: child));
      },
      errorBuilder: (context, error, stackTrace) => contentBuilder(null),
    );
  }
}

/// Foto amplia de fondo; el diseño de la ficha define su unión con los datos.
class _PhotoSurface extends StatelessWidget {
  const _PhotoSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: AspectRatio(aspectRatio: 4 / 3, child: child),
    );
  }
}
