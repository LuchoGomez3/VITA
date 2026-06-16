import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_state.dart';

class SenasaReportPage extends StatefulWidget {
  final String? documentType; // 'DECLARACION_RFID', 'DTE' o 'TRI'

  const SenasaReportPage({super.key, this.documentType});

  @override
  State<SenasaReportPage> createState() => _SenasaReportPageState();
}

class _SenasaReportPageState extends State<SenasaReportPage> {
  late String _selectedFormat;
  late String _title;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  // Estados locales para los formularios desplegables
  String? _selectedOrigen = 'Estancia La Paz (RENSPA: 04.012.3...)';
  String? _selectedDestino = 'Mercado de Liniers (RENSPA: 01.002...)';
  String? _selectedTransportista = 'Transportes Gómez (CUIT: 30-1234...)';

  final List<String> _origenes = ['Estancia La Paz (RENSPA: 04.012.3...)', 'El Carrizal (RENSPA: 08.111.2...)'];
  final List<String> _destinos = [
    'Mercado de Liniers (RENSPA: 01.002...)',
    'Frigorífico Rioplatense',
    'Estancia Los Pinos',
  ];
  final List<String> _transportistas = ['Transportes Gómez (CUIT: 30-1234...)', 'Logística Sur SRL (CUIT: 33-9876...)'];

  @override
  void initState() {
    super.initState();
    if (widget.documentType == 'DECLARACION_RFID') {
      _title = 'Declaración de Dispositivos';
      _selectedFormat = 'TXT';
    } else if (widget.documentType == 'DTE') {
      _title = 'Emisión de DT-e';
      _selectedFormat = 'PDF';
    } else {
      _title = 'Planillas SIGSA';
      _selectedFormat = 'CSV';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDTE = widget.documentType == 'DTE';

    return BlocProvider(
      create: (context) => SenasaReportCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocConsumer<SenasaReportCubit, SenasaReportState>(
            listener: (context, state) {
              if (state is SenasaReportSuccess) {
                Share.shareXFiles([XFile(state.filePath)], text: 'Documento $_title generado en VITA.');
              } else if (state is SenasaReportValidationError) {
                _showValidationBottomSheet(context, state.message, state.invalidAnimals);
              } else if (state is SenasaReportError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  // --- BARRA DE PROGRESO SUPERIOR FIJA ---
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASO 1 DE 2',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Configuración de parámetros',
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
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.50,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),

                  // --- AREA DE SCROLL CENTRAL ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filtros para $_selectedFormat', style: AppTypography.pageTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            isDTE
                                ? 'Establezca las fechas operativas y los datos del traslado para generar el remito.'
                                : 'Establezca las fechas operativas para compilar y validar las lecturas.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // --- SOLUCIÓN: UN SOLO CUADRADO BLANCO CONTENEDOR ---
                          AppSurfaceCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // BLOQUE INTERNO: SELECCIÓN DE FECHAS
                                  const Text(
                                    'Período operativo',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectDate(context, true),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Desde',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        _formatDate(_startDate),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
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
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hasta',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        _formatDate(_endDate),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Divider(), // Línea sutil divisoria interna
                                  ),

                                  // BLOQUE INTERNO: DATOS DE ESTABLECIMIENTO / TRASLADO
                                  Text(
                                    isDTE ? 'Datos del Traslado' : 'Datos del Establecimiento',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _selectedOrigen,
                                    decoration: const InputDecoration(
                                      labelText: 'Establecimiento Origen',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    items: _origenes
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: const TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) => setState(() => _selectedOrigen = val),
                                  ),

                                  if (isDTE) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _selectedDestino,
                                      decoration: const InputDecoration(
                                        labelText: 'Establecimiento Destino',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      items: _destinos
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedDestino = val),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _selectedTransportista,
                                      decoration: const InputDecoration(
                                        labelText: 'Transportista',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      items: _transportistas
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedTransportista = val),
                                    ),
                                  ],

                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Divider(),
                                  ),

                                  // BLOQUE INTERNO: FORMATO DE SALIDA
                                  TextFormField(
                                    initialValue: _selectedFormat,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Formato de Salida Obligatorio',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _selectedFormat == 'TXT'
                                        ? '* Formato estructurado requerido por el portal SIGSA para importación de dispositivos.'
                                        : _selectedFormat == 'CSV'
                                        ? '* Estructura delimitada por comas optimizada para la planilla de existencias.'
                                        : '* Documento visual apto para impresión y firma en soporte físico.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- SOLUCIÓN: BOTÓN DE CONTINUAR FIJO/FLOTANTE ABAJO ---
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        // Reutiliza el estilo de sombras de tu core de diseño si aplica
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppFilledButton(
                        label: state is SenasaReportLoading ? 'Validando registros...' : 'Continuar y Validar',
                        icon: state is SenasaReportLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.arrow_forward),
                        onPressed: state is SenasaReportLoading
                            ? () {}
                            : () {
                                context.read<SenasaReportCubit>().generateReport(
                                  startDate: _startDate,
                                  endDate: _endDate,
                                  movementType: widget.documentType ?? 'GENERAL',
                                  format: _selectedFormat,
                                );
                              },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showValidationBottomSheet(BuildContext context, String message, List<String> invalidAnimals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gpp_bad_outlined, color: Colors.red.shade700, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Inconsistencias críticas de datos detectadas en el lote. Corrija los siguientes animales antes de exportar:',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invalidAnimals.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.red.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.error_outline, color: Colors.red.shade600),
                        title: Text(
                          invalidAnimals[index],
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade900),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.red.shade400),
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
