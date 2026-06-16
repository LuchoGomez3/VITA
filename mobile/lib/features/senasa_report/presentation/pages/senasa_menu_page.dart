import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

class _RecentDocument {
  final String title;
  final String date;
  final String format;
  final String status;
  final IconData icon;

  const _RecentDocument({
    required this.title,
    required this.date,
    required this.format,
    required this.status,
    required this.icon,
  });
}

class SenasaMenuPage extends StatelessWidget {
  const SenasaMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocks del historial
    final List<_RecentDocument> recentDocuments = [
      const _RecentDocument(
        title: 'DT-e - Movimiento de Egreso Tropa 402',
        date: 'Hoy, 14:32',
        format: 'PDF',
        status: 'Generado con éxito',
        icon: Icons.picture_as_pdf,
      ),
      const _RecentDocument(
        title: 'Declaración Dispositivos (Alta Terneros)',
        date: 'Ayer, 09:15',
        format: 'TXT',
        status: 'Exportado para SIGSA',
        icon: Icons.code,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SENASA SIGSA'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(AppRoutes.home)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Documentación Reciente', style: AppTypography.pageTitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Historial de archivos oficiales exportados para SIGSA.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: recentDocuments.length,
                itemBuilder: (context, index) {
                  final doc = recentDocuments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: doc.format == 'PDF' ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(doc.icon, color: doc.format == 'PDF' ? Colors.red.shade700 : Colors.blue.shade700),
                      ),
                      title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        '${doc.date} • ${doc.format}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.share_outlined, size: 20),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: AppFilledButton(
                  label: 'Generar nuevo archivo',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showGenerationOptionsBottomSheet(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerationOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Qué trámite desea realizar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),

                // Opción 1: Archivo TXT para caravanas
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  title: const Text('Declaración de Dispositivos', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Archivo TXT masivo con RFIDs para subir a SIGSA.'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.senasaReport, extra: 'DECLARACION_RFID'); // Enviamos el parámetro
                  },
                ),
                const Divider(),

                // Opción 2: DT-e (PDF)
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined, color: Colors.red),
                  title: const Text('Generación de DT-e', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Documento PDF para el traslado de tropas.'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.senasaReport, extra: 'DTE');
                  },
                ),
                const Divider(),

                // Opción 3: TRI / Existencias
                ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: Colors.green),
                  title: const Text('TRI / Cambio de Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Planilla CSV para actualización de existencias.'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.senasaReport, extra: 'TRI');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
