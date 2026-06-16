import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/weight_gain_chart.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_state.dart';


class AnimalDetailPage extends StatelessWidget {
  const AnimalDetailPage({
    required this.animalId,
    super.key,
  });

  final String animalId;

  void _handleClose(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {



    return BlocProvider(

      create: (context) => AnimalDetailCubit()..loadAnimalData(animalId),

      child: Scaffold(appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
        title: const Text('Detalle de animal'),
      ),


      body: BlocBuilder<AnimalDetailCubit, AnimalDetailState>(
          builder: (context, state) {
            
            if (state is AnimalDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } 
            
            else if (state is AnimalDetailError) {
              return Center(child: Text(state.message));
            } 
            
            else if (state is AnimalDetailLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    //Text('Animal ID: $animalId'),
                    //Text('Raza: ${state.raza}'),
                    //Text('Peso: ${state.pesoActual} kg'),
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    
                    _buildDataRows(),
                    const SizedBox(height: AppSpacing.lg),
                    
                    const WeightGainChart(),

                    AnimalEventHistory(),
                    _buildFooter(),
                    // Aquí puedes poner el _buildHeader(), _buildDataRows(), etc.
                  ],
                ),
              );
            }

            return const SizedBox.shrink(); // Para el estado inicial
          },
          ),
        ),
      );
  }

  /// 1. SECCIÓN SUPERIOR: Círculo verde, ID dinámico y Ubicación
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animalId, // Usamos la variable de tu clase en lugar de texto fijo
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Caravana / ID',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Potrero 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            Text(
              'Ubicación actual',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  /// 2. SECCIÓN CENTRAL: Cuadrícula de información (Raza, Sexo, etc.)
  Widget _buildDataRows() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataCell('Raza', 'Brahman')),
            Expanded(child: _buildDataCell('Sexo', 'Macho')),
            Expanded(child:_buildDataCell('Categoría', 'Novillo'))
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _buildDataCell('Fecha de Nacimiento', '12/11/2024')),
            Expanded(child: _buildDataCell('Edad', '19 meses')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _buildDataCell('Último peso', '410 kg')),
            Expanded(
              child: _buildDataCell(
                'Fuente último peso',
                'Estimación por IA',
                isHighlighted: true, 
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. SECCIÓN INFERIOR: Alertas y fechas
  Widget _buildFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_rounded, color: Colors.green.shade700, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '2 eventos pendientes de\nsincronización',
            style: TextStyle(fontSize: 12, color: Colors.green.shade700),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Última lectura:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Text(
              '10/06/2026',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  /// FUNCIÓN AUXILIAR: Para dibujar cada dato individual en la cuadrícula
  Widget _buildDataCell(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        if (isHighlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}