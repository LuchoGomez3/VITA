import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:go_router/go_router.dart';

class _RecentDocument {
  const _RecentDocument({
    required this.title,
    required this.date,
    required this.format,
    required this.status,
    required this.icon,
  });
  final String title;
  final String date;
  final String format;
  final String status;
  final IconData icon;
}

/// Menu page for recent SENASA documents and report generation entry point.
class SenasaMenuPage extends StatelessWidget {
  /// Crea la pantalla de acceso a reportes SENASA.
  const SenasaMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentDocuments = <_RecentDocument>[
      const _RecentDocument(
        title: 'TRI - Ingreso de Animales',
        date: 'Hoy, 14:32',
        format: 'PDF',
        status: 'Generado con éxito',
        icon: Icons.local_shipping_outlined,
      ),
      const _RecentDocument(
        title: 'Declaración Dispositivos (Alta Terneros)',
        date: 'Ayer, 09:15',
        format: 'TXT',
        status: 'Exportado para SIGSA',
        icon: Icons.qr_code_scanner,
      ),
    ];

    return Scaffold(
      appBar: const AppHeader(
        title: SenasaStrings.menuPageTitle,
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
                  const Text(SenasaStrings.menuPageSubtitle, style: AppTypography.pageTitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    SenasaStrings.menuPageDescription,
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
                  onPressed: () => context.push(AppRoutes.senasaReport),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
