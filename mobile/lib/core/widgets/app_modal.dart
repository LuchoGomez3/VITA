import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Base reutilizable para modales de la app.
class AppModal extends StatelessWidget {
  /// Crea un modal con blur, superficie y espaciado estandar.
  const AppModal({
    required this.title,
    required this.message,
    required this.action,
    super.key,
    this.leading,
    this.content,
    this.titleStyle = AppTypography.connectivityModalTitle,
    this.messageStyle = AppTypography.connectivityModalBody,
  });

  /// Widget destacado al inicio del modal.
  final Widget? leading;

  /// Titulo principal.
  final String title;

  /// Mensaje descriptivo.
  final String message;

  /// Contenido adicional entre el mensaje y la accion.
  final Widget? content;

  /// Accion principal del modal.
  final Widget action;

  /// Estilo del titulo.
  final TextStyle titleStyle;

  /// Estilo del mensaje.
  final TextStyle messageStyle;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: leading,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                title,
                style: titleStyle,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: messageStyle,
              ),
              if (content != null) ...[
                const SizedBox(height: AppSpacing.lg),
                content!,
              ],
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
