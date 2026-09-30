import 'package:flutter/material.dart';

/// Conserva la elipse y la aplana al terminar la compresión del encabezado.
class ProfileHeaderClipper extends CustomClipper<Path> {
  /// Recibe el avance de la transición final, entre cero y uno.
  const ProfileHeaderClipper({required this.transition});

  /// Proporción del cambio desde la elipse hasta el encabezado compacto.
  final double transition;

  @override
  Path getClip(Size size) {
    final depth = 60 * (1 - transition);
    if (depth == 0) return Path()..addRect(Offset.zero & size);

    // Los extremos quedan fuera de pantalla; solo cambia la profundidad,
    // sin repintar ni escalar el degradado que hay debajo de este recorte.
    final overflow = size.width * 0.1;
    final curveStart = size.height - depth;
    return Path()
      ..moveTo(-overflow, 0)
      ..lineTo(size.width + overflow, 0)
      ..lineTo(size.width + overflow, curveStart)
      ..arcToPoint(
        Offset(-overflow, curveStart),
        radius: Radius.elliptical(size.width / 2 + overflow, depth),
      )
      ..close();
  }

  @override
  bool shouldReclip(ProfileHeaderClipper oldClipper) => transition != oldClipper.transition;
}
