import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula el porcentaje objetivo (ej: 0.5 para paso 1 de 2, 1.0 para paso 2 de 2)
    final double targetProgress = currentStep / totalSteps;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Este bloque de textos se mantiene idéntico en dimensiones en ambas pantallas
          // para evitar saltos visuales o parpadeos (glitches).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PASO $currentStep DE $totalSteps',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.1,
                  ),
                ),
                Flexible(
                  child: Text(
                    stepTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // --- LA BARRA DE PROGRESO CON ANIMACIÓN DE DESLIZAMIENTO ---
          // Al usar LayoutBuilder medimos el ancho real disponible para que la barra
          // se desplace de lado a lado rellenando exactamente el espacio físico.
          LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;

              return Container(
                width: availableWidth,
                height: 2.5, // El grosor sutil y minimalista que elegiste
                color: Colors.grey.shade200, // Fondo de la barra no completada
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400), // Velocidad de la transición
                  curve: Curves.easeInOut, // Curva de aceleración suave
                  width: availableWidth * targetProgress,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
