import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/data/repositories/senasa_report_repository_impl.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('SenasaReportRepositoryImpl', () {
    test('maps establishments and sends the bearer token', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v1/establecimientos');
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'f5ad21ed-6e92-4827-8242-9a18f103ab3a',
                'nombre': 'Estancia de prueba',
                'nro_renspa': '04.012.3.00142/00',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repository = _repository(client);

      final establishments = await repository.getEstablishments();

      expect(establishments, hasLength(1));
      expect(establishments.single.name, 'Estancia de prueba');
      expect(establishments.single.renspa, '04.012.3.00142/00');
    });

    test('downloads a report using backend query parameters', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v1/reportes/senasa');
        expect(request.url.queryParameters['formato'], 'csv');
        expect(request.url.queryParameters['tipo_evento'], 'ingreso');
        expect(request.url.queryParameters['incluir_responsable'], 'true');
        return http.Response.bytes(
          utf8.encode('RENSPA,Identificador'),
          200,
          headers: {
            'content-type': 'text/csv; charset=utf-8',
            'content-disposition': 'attachment; filename="reporte_senasa.csv"',
          },
        );
      });
      final repository = _repository(client);

      final report = await repository.generateReport(
        SenasaReportRequest(
          establishmentId: 'f5ad21ed-6e92-4827-8242-9a18f103ab3a',
          format: 'csv',
          from: DateTime.utc(2026, 6),
          to: DateTime.utc(2026, 6, 22, 23, 59, 59),
          eventType: 'ingreso',
          responsibleName: 'Juan Perez',
          responsibleDni: '30111222',
        ),
      );

      expect(report.filename, 'reporte_senasa.csv');
      expect(report.mediaType, 'text/csv');
      expect(utf8.decode(report.bytes), 'RENSPA,Identificador');
    });

    test('surfaces the structured backend validation message', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'errors': [
              {
                'code': 'datos_incompletos_para_reporte',
                'message': 'Hay animales con datos incompletos',
              },
            ],
          }),
          422,
          headers: {'content-type': 'application/json'},
        ),
      );
      final repository = _repository(client);

      await expectLater(
        repository.generateReport(
          SenasaReportRequest(
            establishmentId: 'f5ad21ed-6e92-4827-8242-9a18f103ab3a',
            format: 'pdf',
            from: DateTime.utc(2026, 6),
            to: DateTime.utc(2026, 6, 22),
            eventType: 'egreso',
            responsibleName: 'Juan Perez',
            responsibleDni: '30111222',
          ),
        ),
        throwsA(
          isA<SenasaReportException>().having(
            (error) => error.message,
            'message',
            'Hay animales con datos incompletos',
          ),
        ),
      );
    });
  });
}

SenasaReportRepositoryImpl _repository(http.Client client) {
  return SenasaReportRepositoryImpl(
    baseUrl: 'http://localhost:8000/api',
    accessToken: 'test-token',
    client: client,
  );
}
