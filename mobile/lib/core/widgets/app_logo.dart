import 'package:flutter/material.dart';

/// Logo oficial de VITA reutilizado en las pantallas de acceso.
class AppLogo extends StatelessWidget {
  /// Crea el logo cuadrado con el tamaño y redondeo indicados.
  const AppLogo({
    this.size = 96,
    this.borderRadius = 24,
    super.key,
  });

  /// Ancho y alto del logo.
  final double size;

  /// Radio aplicado a sus esquinas.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
