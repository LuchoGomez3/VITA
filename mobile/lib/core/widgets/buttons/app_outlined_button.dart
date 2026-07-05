import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Boton secundario reutilizable de la app.
///
/// Usa fondo neutro y borde suave. Tambien soporta solo texto o texto con
/// icono segun el caso de uso.
///
/// El texto usa por defecto el estilo configurado para `OutlinedButton` en el
/// tema global. Si una pantalla necesita una excepcion puntual, puede pasar
/// `textStyle` para sobrescribir esta instancia sin tocar el resto de la app.
class AppOutlinedButton extends StatelessWidget {
  /// Crea un boton outlined reutilizable para acciones secundarias.
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.textStyle,
  });

  /// El texto del boton.
  final String label;
  /// El icono del boton.
  final Widget? icon;
  /// La funcion que se ejecuta cuando se presiona el boton.
  final VoidCallback? onPressed;
  /// Indica si el boton esta en estado de carga.
  final bool isLoading;
  /// El estilo del texto del boton.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // Si no se pasa un estilo puntual, usamos el definido globalmente en el
    // tema para mantener consistencia entre pantallas.
    final buttonTextStyle = textStyle ?? Theme.of(context).textTheme.labelMedium;

    // El contenido soporta tres estados simples:
    // loading, solo texto, o icono + texto.
    final child = isLoading
        ? Text(
            'Guardando...',
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
      // Los botones secundarios ocupan todo el ancho disponible por defecto.
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
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
