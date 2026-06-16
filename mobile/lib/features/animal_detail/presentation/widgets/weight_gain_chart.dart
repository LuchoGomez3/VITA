import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightGainChart extends StatelessWidget {
  const WeightGainChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolución de Peso',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Le damos un tamaño fijo de alto al gráfico
        SizedBox(
          height: 200, 
          child: LineChart(
            LineChartData(
              // Límites del gráfico (Y = peso en kg, X = meses)
              minX: 1,
              maxX: 6, // 6 meses de datos
              minY: 200, // Peso mínimo del eje
              maxY: 450, // Peso máximo del eje
              
              // Ocultamos bordes feos
              borderData: FlBorderData(show: false),
              
              // Cuadrícula de fondo
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              
              // Configuración de los textos en los ejes
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                
                // Textos del eje X (Meses)
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.grey, fontSize: 12);
                      String text;
                      switch (value.toInt()) {
                        case 1: text = 'Ene'; break;
                        case 2: text = 'Feb'; break;
                        case 3: text = 'Mar'; break;
                        case 4: text = 'Abr'; break;
                        case 5: text = 'May'; break;
                        case 6: text = 'Jun'; break;
                        default: return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
                
                // Textos del eje Y (Kilos)
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}kg',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
              
              // ¡LA LÍNEA DE DATOS!
              lineBarsData: [
                LineChartBarData(
                  // Puntos: X (mes), Y (kilos)
                  spots: const [
                    FlSpot(1, 250),
                    FlSpot(2, 280),
                    FlSpot(3, 310),
                    FlSpot(4, 340),
                    FlSpot(5, 390),
                    FlSpot(6, 410), // Último peso (Estimación por IA)
                  ],
                  isCurved: true, // Línea suavizada
                  color: Colors.green.shade700, // Tu color verde
                  barWidth: 3, // Grosor de la línea
                  isStrokeCapRound: true,
                  
                  // Puntitos en cada medición
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.green.shade700,
                      );
                    },
                  ),
                  
                  // Sombreado debajo de la línea
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.shade700.withOpacity(0.1), // Sombra verde transparente
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}