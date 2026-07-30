import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Boton primario reutilizable de la app.
///
/// Permite renderizar solo texto o texto con icono segun lo necesite la
/// pantalla que lo consume.
///
/// El texto usa por defecto el estilo configurado para `FilledButton` en el
/// tema global. Si una pantalla necesita una excepcion puntual, puede pasar
/// `textStyle` para sobrescribir esta instancia sin tocar el resto de la app.
class AppFilledButton extends StatelessWidget {
  /// Crea un boton filled reutilizable para acciones primarias.
  const AppFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.loadingLabel = 'Guardando...',
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// El texto del boton.
  final String label;

  /// El icono del boton.
  final Widget? icon;

  /// La funcion que se ejecuta cuando se presiona el boton.
  final VoidCallback? onPressed;

  /// Indica si el boton esta en estado de carga.
  final bool isLoading;

  /// Texto mostrado cuando el boton esta en estado de carga.
  final String loadingLabel;

  /// El estilo del texto del boton.
  final TextStyle? textStyle;

  /// Color de fondo opcional para una variante semantica del boton.
  final Color? backgroundColor;

  /// Color del contenido opcional para una variante semantica del boton.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    // Si no se pasa un estilo puntual, usamos el definido globalmente en el
    // tema para mantener consistencia entre pantallas.
    final buttonTextStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;

    // El contenido soporta tres estados simples:
    // loading, solo texto, o icono + texto.
    final child = isLoading
        ? Text(
            loadingLabel,
            style: buttonTextStyle,
          )
        : icon == null
        ? Text(
            label,
            style: buttonTextStyle,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: buttonTextStyle,
              ),
            ],
          );

    return SizedBox(
      // Los botones principales ocupan todo el ancho disponible por defecto.
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          // El look principal del boton vive en el tema; aca solo reforzamos
          // medidas estructurales propias del componente.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: child,
      ),
    );
  }
}
