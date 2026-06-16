import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_state.dart';
import 'package:frontend_mayoral/app/router/routes.dart';

// Recuerda importar tu Cubit y State
// import 'cubit/senasa_report_cubit.dart';
// import 'cubit/senasa_report_state.dart';

class SenasaReportPage extends StatefulWidget {
  const SenasaReportPage({super.key});

  @override
  State<SenasaReportPage> createState() => _SenasaReportPageState();
}

  void _handleClose(BuildContext context) {
    if (context.canPop()){
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }


class _SenasaReportPageState extends State<SenasaReportPage> {
  String _selectedMovement = 'Egreso';
  String _selectedFormat = 'TXT'; // Cambiado a TXT por defecto para SIGSA
  
  // Variables de estado para las fechas (Por defecto: último mes)
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Función para abrir el calendario
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // No se pueden generar reportes del futuro
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Usa el color principal de tu app
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Validación simple: Si la fecha "desde" es mayor a "hasta", ajustamos la "hasta"
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Validación: Si "hasta" es menor a "desde", ajustamos "desde"
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  // Helper para mostrar la fecha en formato DD/MM/YYYY
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SenasaReportCubit(),
      child: Scaffold(
        appBar: AppBar(
        /// Centra el titulo.
        centerTitle: true,
        /// Boton de cerrar.
        leading: IconButton(
          /// Icono de cerrar.
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context),
        ),
        /// Espacio para el boton de cerrar.
        actions: const [
          /// Espacio para el boton de cerrar.
          SizedBox(width: 48),
        ],
          title: const Text('Documentación SENASA'),
        ),
        
        // Usamos BlocConsumer: escucha alertas y además dibuja la pantalla
        body: BlocConsumer<SenasaReportCubit, SenasaReportState>(
          listener: (context, state) {
            if (state is SenasaReportSuccess) {
              Share.shareXFiles([XFile(state.filePath)], text: 'Adjunto reporte SENASA');
            } 
            else if (state is SenasaReportValidationError) {
              _showValidationBottomSheet(context, state.message, state.invalidAnimals);
            }
            else if (state is SenasaReportError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parámetros del Reporte',
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  AppSurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // --- NUEVO: Selectores de Rango de Fechas ---
                          const Text('Rango de fechas', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context, true),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Desde', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _formatDate(_startDate), 
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context, false),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Hasta', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _formatDate(_endDate), 
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // ---------------------------------------------

                          // Filtro: Tipo de Movimiento
                          DropdownButtonFormField<String>(
                            value: _selectedMovement,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Movimiento',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Ingreso', 'Egreso', 'Cambio de Categoría', 'Mortandad']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedMovement = val!),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Filtro: Formato (Actualizado a TXT)
                          DropdownButtonFormField<String>(
                            value: _selectedFormat,
                            decoration: const InputDecoration(
                              labelText: 'Formato de Exportación',
                              border: OutlineInputBorder(),
                            ),
                            items: ['PDF', 'TXT']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedFormat = val!),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Botón Generar (Añadido envío de fechas al Cubit)
                  SizedBox(
                    width: double.infinity,
                    child: AppFilledButton(
                      label: state is SenasaReportLoading ? 'Generando...' : 'Generar Reporte',
                      icon: state is SenasaReportLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.download),
                      onPressed: state is SenasaReportLoading ? () {} : () {
                        context.read<SenasaReportCubit>().generateReport(
                          startDate: _startDate,
                          endDate: _endDate,
                          movementType: _selectedMovement,
                          format: _selectedFormat,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showValidationBottomSheet(BuildContext context, String title, List<String> animals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Corrija los siguientes registros antes de exportar:'),
              const SizedBox(height: AppSpacing.sm),
              ...animals.map((a) => ListTile(
                leading: const Icon(Icons.pets),
                title: Text(a),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () {},
              )),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      }
    );
  }
}