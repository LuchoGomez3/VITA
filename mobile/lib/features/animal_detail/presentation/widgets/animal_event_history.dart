import 'package:flutter/material.dart';

// 1. Un modelo simple para representar un evento (luego esto vendrá de tu base de datos o API)
class AnimalEvent {
  final String date;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  AnimalEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}

class AnimalEventHistory extends StatelessWidget {
  AnimalEventHistory({super.key});

  // 2. Datos de prueba simulando el historial de trazabilidad
  final List<AnimalEvent> _mockEvents = [
    AnimalEvent(
      date: '10/06/2026',
      title: 'Pesaje registrado',
      description: 'Peso: 410 kg (Estimación por IA).',
      icon: Icons.monitor_weight_outlined,
      iconColor: Colors.blue.shade600,
    ),
    AnimalEvent(
      date: '15/03/2026',
      title: 'Vacunación SENASA',
      description: 'Campaña Antiaftosa y Antibrucélica.',
      icon: Icons.vaccines_outlined,
      iconColor: Colors.red.shade500,
    ),
    AnimalEvent(
      date: '01/02/2026',
      title: 'Movimiento interno',
      description: 'Traslado desde Potrero 1 a Potrero 3.',
      icon: Icons.sync_alt_outlined,
      iconColor: Colors.orange.shade600,
    ),
    AnimalEvent(
      date: '12/11/2024',
      title: 'Alta de animal',
      description: 'Registro inicial en el sistema. Nacimiento.',
      icon: Icons.add_circle_outline,
      iconColor: Colors.green.shade700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Eventos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 3. ListView para dibujar la lista de eventos
        ListView.builder(
          shrinkWrap: true, // Fundamental para que funcione dentro de un SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Evita que la lista tenga su propio scroll interno
          itemCount: _mockEvents.length,
          itemBuilder: (context, index) {
            final event = _mockEvents[index];
            final isLast = index == _mockEvents.length - 1;

            return _buildEventTile(event, isLast);
          },
        ),
      ],
    );
  }

  // 4. El diseño individual de cada fila del historial
  Widget _buildEventTile(AnimalEvent event, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Columna de la izquierda: Fecha e indicador visual
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Columna central: Línea vertical e ícono
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: event.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(event.icon, size: 18, color: event.iconColor),
              ),
              if (!isLast) // Dibuja la línea de conexión si no es el último elemento
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          // Columna de la derecha: Título y descripción
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}