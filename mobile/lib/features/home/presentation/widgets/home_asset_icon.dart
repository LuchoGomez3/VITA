import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Renderiza un SVG del tablero con el color y tamano del sistema visual.
class HomeAssetIcon extends StatelessWidget {
  /// Crea un icono vectorial para los componentes de Inicio.
  const HomeAssetIcon({
    required this.assetPath,
    super.key,
    this.color = AppColors.primary,
    this.size = 24,
  });

  /// Ruta declarada dentro de los assets de la aplicacion.
  final String assetPath;

  /// Color aplicado sobre trazos y rellenos del SVG.
  final Color color;

  /// Alto y ancho del icono.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
