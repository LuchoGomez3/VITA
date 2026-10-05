import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Presenta la foto completa en una superficie consistente con las tarjetas.
class AnimalDetailPhoto extends StatelessWidget {
  /// Crea la foto desde una captura privada o un asset encontrado por caravana.
  const AnimalDetailPhoto({required this.animalDetail, required this.contentBuilder, super.key});

  /// Contiene las referencias locales resueltas por la capa de datos.
  final AnimalDetail animalDetail;

  /// Construye la ficha con una foto válida o con null para el diseño original.
  /// La misma decisión controla la imagen grande y el círculo del encabezado.
  final Widget Function(Widget? photo) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final path = animalDetail.localPhotoPath;
    final assetPath = animalDetail.photoAssetPath;
    if (path == null && assetPath == null) return contentBuilder(null);

    return Image(
      image: path != null ? FileImage(File(path)) : AssetImage(assetPath!),
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
