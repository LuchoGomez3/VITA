import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/senasa_report/data/repositories/senasa_report_repository_impl.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const establishmentId = 'f5ad21ed-6e92-4827-8242-9a18f103ab3a';

  group('SenasaReportRepositoryImpl', () {
    test('obtiene los establecimientos desde el catálogo local', () async {
      final storage = _MemoryStorage(
        jsonEncode([
          {
            'id': establishmentId,
            'name': 'Estancia local',
            'renspa_number': '04.012.3.00142/00',
          },
        ]),
      );
      final repository = _repository(
        MockClient((_) async => throw StateError('No debe usar la red')),
        secureStorage: storage,
      );

      final establishments = await repository.getEstablishments();

      expect(establishments.single.name, 'Estancia local');
      expect(establishments.single.renspa, '04.012.3.00142/00');
    });

    test('validar usa POST específico y no descarga un archivo', () async {
      var requests = 0;
      final repository = _repository(
        MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(
            request.url.path,
            '/api/v1/reportes/senasa/declaraciones_dispositivos/validacion',
          );
          expect(request.headers['Authorization'], 'Bearer test-token');
          expect(jsonDecode(request.body), {
            'establecimientoId': establishmentId,
            'desde': '2026-08-01T00:00:00.000Z',
            'hasta': '2026-08-08T23:59:59.000Z',
            'nombreArchivo': 'declaracion_agosto',
          });
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'cantidadExportable': 10,
                'animalesIncompletos': <Object?>[],
              },
            }),
            200,
          );
        }),
      );

      final result = await repository.validateRecords(
        SenasaReportValidationRequest(
          establishmentId: establishmentId,
          from: DateTime.utc(2026, 8),
          to: DateTime.utc(2026, 8, 8, 23, 59, 59),
          fileName: 'declaracion_agosto',
        ),
      );

      expect(requests, 1);
      expect(result.exportableAnimals, 10);
      expect(result.issues, isEmpty);
    });

    test('mapea todos los animales incompletos', () async {
      final repository = _repository(
        MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'cantidad_exportable': 1,
                'animales_incompletos': [
                  {
                    'animal_id': 'animal-1',
                    'caravana': '123',
                    'faltante': ['raza'],
                  },
                ],
              },
            }),
            200,
          ),
        ),
      );

      final result = await repository.validateRecords(
        SenasaReportValidationRequest(
          establishmentId: establishmentId,
          from: DateTime.utc(2026, 8),
          to: DateTime.utc(2026, 8, 8),
          fileName: '',
        ),
      );

      expect(result.issues.single.tag, '123');
      expect(result.issues.single.missingFields, ['raza']);
    });

    test('generar usa POST y conserva bytes y Content-Disposition', () async {
      final repository = _repository(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.path,
            '/api/v1/reportes/senasa/declaraciones_dispositivos',
          );
          return http.Response.bytes(
            utf8.encode('123-H-AA-08/2026'),
            200,
            headers: {
              'content-type': 'text/plain; charset=utf-8',
              'content-disposition': 'attachment; filename="declaracion_agosto.txt"',
            },
          );
        }),
      );

      final report = await repository.generateReport(
        SenasaReportRequest(
          establishmentId: establishmentId,
          from: DateTime.utc(2026, 8),
          to: DateTime.utc(2026, 8, 8, 23, 59, 59),
          fileName: 'declaracion_agosto',
          animalCount: 1,
        ),
      );

      expect(report.filename, 'declaracion_agosto.txt');
      expect(report.mediaType, 'text/plain');
      expect(utf8.decode(report.bytes), '123-H-AA-08/2026');
    });

    test('obtiene historial remoto por establecimiento', () async {
      final repository = _repository(
        MockClient((request) async {
          expect(request.url.queryParameters['establecimiento_id'], establishmentId);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'export-1',
                  'establecimiento_id': establishmentId,
                  'nombre_archivo': 'declaracion.txt',
                  'media_type': 'text/plain',
                  'cantidad_animales': 4,
                  'created_at': '2026-08-08T12:00:00Z',
                  'desde': '2026-08-01T00:00:00Z',
                  'hasta': '2026-08-08T23:59:59Z',
                },
              ],
            }),
            200,
          );
        }),
      );

      final history = await repository.getGeneratedReports(establishmentId);

      expect(history.single.filename, 'declaracion.txt');
      expect(history.single.animalCount, 4);
    });

    test('vuelve a descargar el archivo histórico original', () async {
      final repository = _repository(
        MockClient((request) async {
          expect(
            request.url.path,
            '/api/v1/reportes/senasa/exportaciones/export-1/descarga',
          );
          return http.Response.bytes(
            utf8.encode('contenido-original'),
            200,
            headers: {
              'content-type': 'text/plain',
              'content-disposition': 'attachment; filename="original.txt"',
            },
          );
        }),
      );

      final report = await repository.downloadGeneratedReport('export-1');

      expect(report.filename, 'original.txt');
      expect(utf8.decode(report.bytes), 'contenido-original');
    });

    test('expone un mensaje comprensible sin conexión', () async {
      final repository = _repository(
        MockClient((_) async => throw http.ClientException('offline')),
      );

      await expectLater(
        repository.validateRecords(
          SenasaReportValidationRequest(
            establishmentId: establishmentId,
            from: DateTime.utc(2026, 8),
            to: DateTime.utc(2026, 8, 8),
            fileName: '',
          ),
        ),
        throwsA(
          isA<SenasaReportException>().having(
            (error) => error.message,
            'message',
            contains('El formulario conserva tus datos'),
          ),
        ),
      );
    });
  });
}

SenasaReportRepositoryImpl _repository(
  http.Client client, {
  SecureStorageService? secureStorage,
}) {
  return SenasaReportRepositoryImpl(
    baseUrl: 'https://example.test',
    tokenProvider: _TokenProvider(),
    secureStorage: secureStorage ?? _MemoryStorage(),
    client: client,
  );
}

class _MemoryStorage implements SecureStorageService {
  _MemoryStorage([this.value]);

  String? value;

  @override
  Future<void> delete(String key) async => value = null;

  @override
  Future<String?> read(String key) async => value;

  @override
  Future<void> write({required String key, required String value}) async {
    this.value = value;
  }
}

class _TokenProvider implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'test-token';
}
